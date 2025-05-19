# PowerShell Welcome Script for Chezmoi Dotfiles Setup

# Display ASCII art
function Show-WelcomeArt {
    Write-Host -ForegroundColor Cyan @"
    ███╗   ███╗██╗  ██╗     ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
    ████╗ ████║██║ ██╔╝    ██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
    ██╔████╔██║█████╔╝     ██║   ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
    ██║╚██╔╝██║██╔═██╗     ██║   ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
    ██║ ╚═╝ ██║██║  ██╗    ╚██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
    ╚═╝     ╚═╝╚═╝  ╚═╝     ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
                                     MK-DOTFILES
"@
}

# Show welcome information
function Show-WelcomeInfo {
    Write-Host ""
    Write-Host -ForegroundColor Cyan "ℹ️  Welcome, $($env:USERNAME)! Setting up your dotfiles..."
    Write-Host -ForegroundColor Cyan "ℹ️  Detected OS: Windows $(Get-ComputerInfo | Select-Object WindowsProductName).WindowsProductName"
    Write-Host -ForegroundColor Cyan "ℹ️  Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host ""
}

# Main execution
Show-WelcomeArt
Show-WelcomeInfo

# Small delay to let user read the welcome message
Start-Sleep -Seconds 2

# Exit successfully
exit 0
