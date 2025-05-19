# Windows Package Installation Script
# Similar to your Brewfile but for Windows using Winget/Chocolatey

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "This script must be run as Administrator. Right-click PowerShell and select 'Run as Administrator'."
    exit 1
}

# Functions
function Install-IfNotPresent {
    param(
        [string]$PackageName,
        [string]$WingetId = "",
        [string]$ChocoId = "",
        [switch]$UseChoco = $false
    )

    $packageInstalled = $false

    # Try Winget first unless Choco is specified
    if (-not $UseChoco -and $WingetId -ne "") {
        Write-Host "Checking if $PackageName is installed via Winget..." -ForegroundColor Yellow
        $checkWinget = winget list --id $WingetId --accept-source-agreements 2>$null

        if ($checkWinget -match $WingetId) {
            Write-Host "$PackageName is already installed." -ForegroundColor Green
            $packageInstalled = $true
        } else {
            Write-Host "Installing $PackageName via Winget..." -ForegroundColor Cyan
            winget install --id $WingetId --accept-source-agreements --accept-package-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "$PackageName installed successfully." -ForegroundColor Green
                $packageInstalled = $true
            }
        }
    }

    # Try Chocolatey if Winget failed or if Choco is specified
    if (-not $packageInstalled -and $ChocoId -ne "") {
        Write-Host "Checking if $PackageName is installed via Chocolatey..." -ForegroundColor Yellow
        $checkChoco = choco list --local-only $ChocoId 2>$null

        if ($checkChoco -match $ChocoId) {
            Write-Host "$PackageName is already installed." -ForegroundColor Green
        } else {
            Write-Host "Installing $PackageName via Chocolatey..." -ForegroundColor Cyan
            choco install $ChocoId -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "$PackageName installed successfully." -ForegroundColor Green
            } else {
                Write-Host "Failed to install $PackageName." -ForegroundColor Red
            }
        }
    }
}

# Ensure Chocolatey is installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    refreshenv
} else {
    Write-Host "Chocolatey is already installed." -ForegroundColor Green
}

# Ensure Winget is installed
try {
    $wingetVersion = winget --version
    Write-Host "Winget is already installed: $wingetVersion" -ForegroundColor Green
} catch {
    Write-Host "Winget not found. It should be included in recent Windows versions." -ForegroundColor Red
    Write-Host "You can install it from the Microsoft Store (App Installer)." -ForegroundColor Yellow
}

# Install Oh My Posh for PowerShell
Install-IfNotPresent -PackageName "Oh My Posh" -WingetId "JanDeDobbeleer.OhMyPosh" -ChocoId "oh-my-posh"

# Install Nerd Fonts (JetBrains Mono)
Install-IfNotPresent -PackageName "JetBrainsMono Nerd Font" -ChocoId "jetbrainsmono-nf" -UseChoco

# Install command line utils (similar to your Linux setup)
Install-IfNotPresent -PackageName "Git" -WingetId "Git.Git" -ChocoId "git"
Install-IfNotPresent -PackageName "Windows Terminal" -WingetId "Microsoft.WindowsTerminal" -ChocoId "microsoft-windows-terminal"
Install-IfNotPresent -PackageName "PowerShell Core" -WingetId "Microsoft.PowerShell" -ChocoId "powershell-core"
Install-IfNotPresent -PackageName "Neovim" -WingetId "Neovim.Neovim" -ChocoId "neovim"
Install-IfNotPresent -PackageName "VSCode" -WingetId "Microsoft.VisualStudioCode" -ChocoId "vscode"
Install-IfNotPresent -PackageName "7-Zip" -WingetId "7zip.7zip" -ChocoId "7zip"
Install-IfNotPresent -PackageName "Bat" -WingetId "sharkdp.bat" -ChocoId "bat"
Install-IfNotPresent -PackageName "Ripgrep" -WingetId "BurntSushi.ripgrep.MSVC" -ChocoId "ripgrep"
Install-IfNotPresent -PackageName "fzf" -WingetId "junegunn.fzf" -ChocoId "fzf"
Install-IfNotPresent -PackageName "fd" -WingetId "sharkdp.fd" -ChocoId "fd"
Install-IfNotPresent -PackageName "jq" -WingetId "jqlang.jq" -ChocoId "jq"
Install-IfNotPresent -PackageName "Starship" -WingetId "Starship.Starship" -ChocoId "starship"
Install-IfNotPresent -PackageName "WinGet CLI" -ChocoId "wingetui" -UseChoco

# Development Tools (similar to your Linux setup)
Install-IfNotPresent -PackageName "Docker Desktop" -WingetId "Docker.DockerDesktop" -ChocoId "docker-desktop"
Install-IfNotPresent -PackageName "Python" -WingetId "Python.Python.3.11" -ChocoId "python311"
Install-IfNotPresent -PackageName "Node.js" -WingetId "OpenJS.NodeJS.LTS" -ChocoId "nodejs-lts"
Install-IfNotPresent -PackageName "Kubectl" -WingetId "Kubernetes.kubectl" -ChocoId "kubernetes-cli"
Install-IfNotPresent -PackageName "Kubernetes Helm" -WingetId "Helm.Helm" -ChocoId "kubernetes-helm"
Install-IfNotPresent -PackageName "Go" -WingetId "GoLang.Go" -ChocoId "golang"
Install-IfNotPresent -PackageName "Terraform" -WingetId "Hashicorp.Terraform" -ChocoId "terraform"
Install-IfNotPresent -PackageName "AWS CLI" -WingetId "Amazon.AWSCLI" -ChocoId "awscli"
Install-IfNotPresent -PackageName "GitHub CLI" -WingetId "GitHub.cli" -ChocoId "gh"

# PowerShell Modules Installation
Write-Host "Installing PowerShell modules..." -ForegroundColor Cyan
$modules = @(
    "PSReadLine",
    "posh-git",
    "Terminal-Icons"
)

foreach ($module in $modules) {
    if (Get-Module -ListAvailable -Name $module) {
        Write-Host "Module $module is already installed." -ForegroundColor Green
    } else {
        Write-Host "Installing module $module..." -ForegroundColor Yellow
        Install-Module -Name $module -Force -Scope CurrentUser
    }
}

Write-Host "All installations complete!" -ForegroundColor Green
