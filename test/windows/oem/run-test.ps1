#Requires -Version 5.1
<#
.SYNOPSIS
    Fresh-install test of the dotfiles inside the dockur/windows VM.

.DESCRIPTION
    1. Installs chezmoi with its official installer (no git or winget needed).
    2. Puts the dotfiles in chezmoi's default source dir: a copy of Z:\ (the
       repo checkout on the Docker host), or a clone of -Repo.
    3. Runs `chezmoi init` interactively. Answer the prompts and paste the BWS
       token yourself. This step is NOT logged, so the token stays out of logs.
    4. Runs `chezmoi apply --verbose`, logged to Z:\.test-logs\.

.PARAMETER Repo
    Clone this URL instead of copying Z:\ (e.g. https://github.com/markkpamy/dotfiles.git).

.EXAMPLE
    # From the desktop launcher, or:
    powershell -ExecutionPolicy Bypass -File Z:\test\windows\oem\run-test.ps1
#>
[CmdletBinding()]
param(
    [string]$Repo,
    [string]$Shared = 'Z:\'
)

$ErrorActionPreference = 'Stop'
$started = Get-Date
$logDir = Join-Path $Shared '.test-logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir ("{0:yyyyMMdd-HHmmss}-{1}.log" -f $started, $env:COMPUTERNAME)

function Write-Step([string]$Message) {
    Write-Host "`n==> $Message" -ForegroundColor Cyan
    Add-Content -Path $log -Value "==> $Message"
}

# Native commands write progress to stderr; don't let PS 5.1 turn that into terminating errors.
function Invoke-Logged([scriptblock]$Command) {
    $ErrorActionPreference = 'Continue'
    & $Command 2>&1 | ForEach-Object { "$_" } | Tee-Object -FilePath $log -Append | Out-Host
    return $LASTEXITCODE
}

$sourceDir = Join-Path $HOME '.local\share\chezmoi'
$binDir = Join-Path $HOME '.local\bin'

if (Test-Path $sourceDir) {
    throw "$sourceDir already exists, so this VM isn't fresh. Run './reset.sh restore' on the Docker host first."
}

# Make sure the token comes from the prompt, as on a real first install.
Remove-Item Env:BWS_ACCESS_TOKEN -ErrorAction SilentlyContinue

Write-Step 'Installing chezmoi'
if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null
    Invoke-Expression "&{$(Invoke-RestMethod 'https://get.chezmoi.io/ps1')} -b '$binDir'"
    $env:Path = "$binDir;$env:Path"
}
Invoke-Logged { chezmoi --version } | Out-Null

if ($Repo) {
    Write-Step "chezmoi init $Repo  (answer the prompts; this step is not logged)"
    chezmoi init $Repo
} else {
    Write-Step "Copying $Shared to $sourceDir"
    robocopy $Shared $sourceDir /E /XD node_modules .cache_ggshield .idea .claude .test-logs /NFL /NDL /NJH /NJS /NP | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed with exit code $LASTEXITCODE" }
    Write-Step 'chezmoi init  (answer the prompts; this step is not logged)'
    chezmoi init
}
if ($LASTEXITCODE) { throw "chezmoi init failed with exit code $LASTEXITCODE" }

Write-Step 'chezmoi apply --verbose'
$applyExit = Invoke-Logged { chezmoi apply --verbose }

Write-Step 'chezmoi status (anything listed was not applied)'
Invoke-Logged { chezmoi status } | Out-Null

Write-Step 'chezmoi doctor'
Invoke-Logged { chezmoi doctor } | Out-Null

$result = if ($applyExit) { "FAILED (chezmoi apply exit code $applyExit)" } else { 'OK' }
$elapsed = (Get-Date) - $started
Write-Step ("Result: {0} in {1:hh\:mm\:ss}. Log: {2}" -f $result, $elapsed, $log)
