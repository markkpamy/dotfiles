#Requires -Version 5.1
<#
.SYNOPSIS
    Fresh-install test of the dotfiles inside the test VM (dockur/windows or Hyper-V).

.DESCRIPTION
    1. Installs chezmoi with its official installer (no git or winget needed).
    2. Puts the dotfiles in chezmoi's default source dir: a copy of the repo
       (-Shared), or a clone of -Repo.
    3. Runs `chezmoi init` interactively. Answer the prompts and paste the BWS
       token yourself. This step is NOT logged, so the token stays out of logs.
    4. Runs `chezmoi apply --verbose`, logged to -LogDir.

.PARAMETER Shared
    The repo copy to install from. Default: Z:\ (dockur shares the host checkout there),
    else C:\dotfiles-src (Hyper-V: pushed in by vm.ps1 and unpacked by the launcher).

.PARAMETER LogDir
    Default: Z:\.test-logs (lands in the host checkout), else C:\test-logs
    (Hyper-V: fetch with `vm.ps1 logs`).

.PARAMETER Repo
    Clone this URL instead of copying -Shared (e.g. https://github.com/markkpamy/dotfiles.git).

.EXAMPLE
    # From the desktop launcher, or:
    powershell -ExecutionPolicy Bypass -File Z:\test\windows\oem\run-test.ps1
#>
[CmdletBinding()]
param(
    [string]$Repo,
    [string]$Shared,
    [string]$LogDir
)

$ErrorActionPreference = 'Stop'
$started = Get-Date
$onDockur = Test-Path 'Z:\test\windows'
if (-not $Shared) { $Shared = if ($onDockur) { 'Z:\' } else { 'C:\dotfiles-src' } }
if (-not $LogDir) { $LogDir = if ($onDockur) { 'Z:\.test-logs' } else { 'C:\test-logs' } }
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
    throw "$sourceDir already exists, so this VM isn't fresh. Restore the clean state first (reset.ps1 / reset.sh / hyperv\vm.ps1 restore)."
}

# Make sure the token comes from the prompt, as on a real first install.
Remove-Item Env:BWS_ACCESS_TOKEN -ErrorAction SilentlyContinue

# Right after boot (or a host network change) the VM's DNS can fail for a while,
# notably behind Hyper-V's Default Switch. Wait for it instead of failing the run.
Write-Step 'Waiting for DNS'
$deadline = (Get-Date).AddMinutes(3)
foreach ($name in 'get.chezmoi.io', 'github.com') {
    while ($true) {
        try { Resolve-DnsName $name -Type A -DnsOnly -ErrorAction Stop | Out-Null; break }
        catch {
            if ((Get-Date) -gt $deadline) { throw "DNS still can't resolve $name after 3 minutes. Check the VM's network." }
            Write-Host "  $name not resolvable yet, retrying..."
            Start-Sleep -Seconds 5
        }
    }
}

Write-Step 'Installing chezmoi'
if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null
    # The installer fetches the binary from GitHub: retry the whole thing on transient network errors.
    for ($attempt = 1; ; $attempt++) {
        try {
            Invoke-Expression "&{$(Invoke-RestMethod 'https://get.chezmoi.io/ps1')} -b '$binDir'"
            if (Test-Path (Join-Path $binDir 'chezmoi.exe')) { break }
            throw 'chezmoi.exe was not installed.'
        } catch {
            if ($attempt -ge 4) { throw }
            Write-Host "  Install attempt $attempt failed: $($_.Exception.Message). Retrying in $(5 * $attempt) s..."
            Start-Sleep -Seconds (5 * $attempt)
        }
    }
    $env:Path = "$binDir;$env:Path"
}
Invoke-Logged { chezmoi --version } | Out-Null

if ($Repo) {
    Write-Step "chezmoi init $Repo  (answer the prompts; this step is not logged)"
    chezmoi init $Repo
} else {
    if (-not (Test-Path (Join-Path $Shared 'home'))) {
        throw "No repo at $Shared. On Hyper-V, run '.\vm.ps1 push' on the host, then start the launcher again."
    }
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
