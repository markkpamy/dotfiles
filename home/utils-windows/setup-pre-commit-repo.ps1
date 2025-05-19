# PowerShell script to set up pre-commit in the current Git repository

# Check if we're in a Git repository
try {
    git rev-parse --git-dir *> $null
} catch {
    Write-Host "❌ Error: Not in a Git repository!" -ForegroundColor Red
    Write-Host "Please run this script from within a Git repository." -ForegroundColor Yellow
    exit 1
}

# Check if pre-commit is installed
if (-not (Get-Command pre-commit -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Error: pre-commit is not installed!" -ForegroundColor Red
    Write-Host "Please install pre-commit first by running: .\utils-windows\install-pre-commit.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "Setting up pre-commit in this repository..." -ForegroundColor Green

# Install pre-commit Git hooks
Write-Host "Installing pre-commit Git hooks..." -ForegroundColor Yellow
pre-commit install --install-hooks

# Install commit-msg hook for commitizen (if using)
Write-Host "Installing commit-msg hook..." -ForegroundColor Yellow
pre-commit install --hook-type commit-msg

# Install pre-push hook
Write-Host "Installing pre-push hook..." -ForegroundColor Yellow
pre-commit install --hook-type pre-push

# Optionally run pre-commit on all files
$runOnAll = Read-Host "Run pre-commit on all files? This may take some time. (y/N)"
if ($runOnAll -match "^[Yy]") {
    Write-Host "Running pre-commit on all files..." -ForegroundColor Yellow
    pre-commit run --all-files
}

Write-Host "✅ Pre-commit setup completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 What happens now:" -ForegroundColor Blue
Write-Host "- Pre-commit hooks will run automatically before each commit" -ForegroundColor Blue
Write-Host "- To manually run all hooks: pre-commit run --all-files" -ForegroundColor Blue
Write-Host "- To update hooks: pre-commit autoupdate" -ForegroundColor Blue
Write-Host "- To bypass hooks (not recommended): git commit --no-verify" -ForegroundColor Blue
