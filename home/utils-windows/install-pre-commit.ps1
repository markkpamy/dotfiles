# PowerShell script to install pre-commit on Windows

Write-Host "Setting up pre-commit framework..." -ForegroundColor Green

# Check if Python is installed
if (-not (Get-Command python -ErrorAction SilentlyContinue) -and -not (Get-Command python3 -ErrorAction SilentlyContinue)) {
    Write-Host "Python is required for pre-commit. Installing via winget..." -ForegroundColor Yellow
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install Python.Python.3
    } else {
        Write-Host "❌ Python not found and winget not available. Please install Python manually." -ForegroundColor Red
        exit 1
    }
}

# Install pre-commit
try {
    Write-Host "Installing pre-commit via pip..." -ForegroundColor Yellow
    if (Get-Command python3 -ErrorAction SilentlyContinue) {
        python3 -m pip install --user pre-commit
    } else {
        python -m pip install --user pre-commit
    }
    Write-Host "✅ Pre-commit installed successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to install pre-commit via pip. Trying alternative methods..." -ForegroundColor Red

    # Try with scoop if available
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Installing pre-commit via scoop..." -ForegroundColor Yellow
        scoop install pre-commit
    }
    # Try with chocolatey if available
    elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Installing pre-commit via chocolatey..." -ForegroundColor Yellow
        choco install pre-commit -y
    }
    else {
        Write-Host "❌ Unable to install pre-commit. Please install manually." -ForegroundColor Red
        Write-Host "Visit: https://pre-commit.com/#install" -ForegroundColor Blue
        exit 1
    }
}

# Refresh PATH to include user scripts
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

# Verify installation
if (Get-Command pre-commit -ErrorAction SilentlyContinue) {
    Write-Host "✅ Pre-commit successfully installed!" -ForegroundColor Green
    pre-commit --version

    Write-Host ""
    Write-Host "Setting up pre-commit in Git repositories..." -ForegroundColor Green
    Write-Host "Run 'pre-commit install' in each Git repository where you want to use pre-commit." -ForegroundColor Blue
    Write-Host "Or run 'pre-commit install --install-hooks -t pre-commit -t commit-msg' for full setup." -ForegroundColor Blue
} else {
    Write-Host "❌ Pre-commit installation verification failed!" -ForegroundColor Red
    Write-Host "You may need to restart your terminal or refresh your PATH environment variable." -ForegroundColor Yellow
}
