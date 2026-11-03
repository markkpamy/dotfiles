#Requires -Version 5.1
<#
.SYNOPSIS
    Windows host (Docker Desktop): save or restore the clean-Windows disk of the dotfiles test VM.
    (On a Linux host use reset.sh.)

.DESCRIPTION
    save     stop the VM and copy its disk volume to the golden volume
    restore  put the golden disk back and start the VM
    status   show the size of both volumes

    The downloaded ISO is never copied or deleted, so a restore never re-downloads Windows.
    Copies run in a throwaway Debian container and keep the disk image sparse.
#>
param(
    [Parameter(Mandatory)][ValidateSet('save', 'restore', 'status')][string]$Action
)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$storage = 'dotfiles-windows-storage'
$golden = 'dotfiles-windows-golden'

# Replace everything in /to except *.iso with the contents of /from (except *.iso).
# Only single quotes inside: Windows PowerShell 5.1 mangles embedded double quotes in native arguments.
$copy = "find /to -mindepth 1 -maxdepth 1 ! -name '*.iso' -exec rm -rf {} + && " +
        "find /from -mindepth 1 -maxdepth 1 ! -name '*.iso' -exec cp -a --sparse=always {} /to/ \;"

function Invoke-Docker {
    & docker @args
    if ($LASTEXITCODE) { throw "docker $($args -join ' ') failed with exit code $LASTEXITCODE" }
}

function Copy-Volume([string]$From, [string]$To) {
    Invoke-Docker run --rm -v "${From}:/from:ro" -v "${To}:/to" debian:stable-slim sh -c $copy
}

function Test-GoldenImage {
    $files = & docker run --rm -v "${golden}:/g:ro" debian:stable-slim sh -c 'ls -A /g'
    return [bool]$files
}

switch ($Action) {
    'save' {
        Invoke-Docker compose stop
        Invoke-Docker volume create $golden | Out-Null
        Copy-Volume $storage $golden
        Write-Host "Golden image saved to volume $golden"
    }
    'restore' {
        if (-not (Test-GoldenImage)) { throw "Volume $golden is empty: run '.\reset.ps1 save' after the first install." }
        Invoke-Docker compose down
        Copy-Volume $golden $storage
        Invoke-Docker compose up -d
        Write-Host 'Restored. Connect with: mstsc /v:localhost:3390  (RDP_PORT in .env), or http://localhost:8006'
    }
    'status' {
        foreach ($v in $storage, $golden) {
            Write-Host "== $v"
            & docker run --rm -v "${v}:/v:ro" debian:stable-slim sh -c 'du -sh /v; du -sh --apparent-size /v; ls -la /v' 2>&1
        }
    }
}
