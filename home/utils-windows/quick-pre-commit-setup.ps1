# Quick setup script to initialize pre-commit in a new repository

Write-Host "🚀 Quick Pre-commit Setup Script" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Check if we're in a Git repository
try {
    git rev-parse --git-dir *> $null
} catch {
    Write-Host "❌ Not in a Git repository. Initializing one..." -ForegroundColor Red
    $initGit = Read-Host "Initialize Git repository here? (y/N)"
    if ($initGit -match "^[Yy]") {
        git init
        Write-Host "✅ Git repository initialized" -ForegroundColor Green
    } else {
        Write-Host "❌ Exiting. Please run this script in a Git repository." -ForegroundColor Red
        exit 1
    }
}

# Check if pre-commit is installed
if (-not (Get-Command pre-commit -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Pre-commit not found. Installing..." -ForegroundColor Red

    # Try different installation methods
    try {
        if (Get-Command python3 -ErrorAction SilentlyContinue) {
            python3 -m pip install --user pre-commit
        } elseif (Get-Command python -ErrorAction SilentlyContinue) {
            python -m pip install --user pre-commit
        } else {
            throw "Python not found"
        }
        # Refresh PATH
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
    } catch {
        # Try alternative package managers
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            scoop install pre-commit
        } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
            choco install pre-commit -y
        } else {
            Write-Host "❌ Unable to install pre-commit automatically." -ForegroundColor Red
            Write-Host "Please install pre-commit manually: https://pre-commit.com/#install" -ForegroundColor Blue
            exit 1
        }
    }
}

# Copy pre-commit config if it exists in home directory
$HomePreCommitConfig = Join-Path $env:USERPROFILE ".pre-commit-config.yaml"
if (Test-Path $HomePreCommitConfig) {
    Write-Host "📋 Copying pre-commit config from home directory..." -ForegroundColor Yellow
    Copy-Item $HomePreCommitConfig .
} elseif (-not (Test-Path ".pre-commit-config.yaml")) {
    Write-Host "📝 Creating basic pre-commit config..." -ForegroundColor Yellow
    @"
# Basic pre-commit configuration
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.2
    hooks:
      - id: gitleaks
"@ | Out-File -FilePath ".pre-commit-config.yaml" -Encoding UTF8
}

# Install hooks
Write-Host "🔧 Installing pre-commit hooks..." -ForegroundColor Yellow
try {
    pre-commit install --install-hooks
    pre-commit install --hook-type commit-msg

    # Optional: Run on all files
    $runAll = Read-Host "🔍 Run pre-commit on all existing files? (y/N)"
    if ($runAll -match "^[Yy]") {
        Write-Host "🏃 Running pre-commit on all files..." -ForegroundColor Yellow
        pre-commit run --all-files
    }

    Write-Host ""
    Write-Host "✅ Pre-commit setup completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Next steps:" -ForegroundColor Blue
    Write-Host "• Pre-commit will now run automatically on each commit" -ForegroundColor Blue
    Write-Host "• Configure .pre-commit-config.yaml to add/remove hooks" -ForegroundColor Blue
    Write-Host "• Run 'pre-commit run --all-files' to check all files" -ForegroundColor Blue
    Write-Host "• Run 'pre-commit autoupdate' to update hook versions" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Happy coding! 🎉" -ForegroundColor Magenta
} catch {
    Write-Host "❌ Error setting up pre-commit hooks: $_" -ForegroundColor Red
    Write-Host "You may need to install pre-commit manually or check your Python installation." -ForegroundColor Yellow
}
