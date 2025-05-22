# PowerShell Welcome Script for Chezmoi Dotfiles Setup

# Display ASCII art
function Show-WelcomeArt {
    Write-Host -ForegroundColor Cyan @"
     __  __ _  __     ____   ___ _____ _____ ___ _     _____ ____
    |  \/  | |/ /    |  _ \ / _ \_   _|  ___|_ _| |   | ____/ ___|
    | |\/| | ' /_____| | | | | | || | | |_   | || |   |  _| \___ \
    | |  | | . \_____| |_| | |_| || | |  _|  | || |___| |___ ___) |
    |_|  |_|_|\_\    |____/ \___/ |_| |_|   |___|_____|_____|____/
"@
}

# Show welcome information
function Show-WelcomeInfo {
    Write-Host ""
    Write-Host -ForegroundColor Cyan "[INFO] Welcome, $($env:USERNAME)! Setting up your dotfiles..."
    Write-Host -ForegroundColor Cyan "[INFO] Detected OS: Windows $(Get-ComputerInfo | Select-Object WindowsProductName).WindowsProductName"
    Write-Host -ForegroundColor Cyan "[INFO] Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host ""
}

# Main execution
Show-WelcomeArt
Show-WelcomeInfo

# Small delay to let user read the welcome message
Start-Sleep -Seconds 2

# Exit successfully
exit 0
