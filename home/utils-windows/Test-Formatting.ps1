# Test script to demonstrate all PowerShell formatting features

# Import formatting library
$FormattingPath = Join-Path (Split-Path $PSScriptRoot) ".chezmoitemplates\powershell\formatting.ps1"
. $FormattingPath

# Demonstration script
Write-Header "PowerShell Formatting Test" "Demonstrating all available formatting options" $script:Icons.Check

# Set total steps for progress tracking
Set-TotalSteps 8

# Step 1: Basic messages
Write-Step 1 "Testing basic message types"
Write-Success "This is a success message"
Write-ErrorFormatted "This is an error message (increments failed counter)"
Write-Warning "This is a warning message"
Write-Info "This is an info message"
Write-Skipped "This is a skipped message (increments skipped counter)"

# Step 2: Actions with different icons
Write-Step 2 "Testing action messages with icons"
Write-Action "Installing" "example package" $script:Icons.Package
Write-Action "Downloading" "file from server" $script:Icons.Download
Write-Action "Configuring" "system settings" $script:Icons.Config
Write-Action "Checking" "dependencies" $script:Icons.Check

# Step 3: Command checking
Write-Step 3 "Testing command availability checks"
Test-CommandAvailable "powershell" "PowerShell"
Test-CommandAvailable "nonexistent_command" "Non-existent command"
Test-RequiredCommands @("powershell", "cmd")

# Step 4: Progress bars
Write-Step 4 "Testing progress bars"
Write-Host "Installing packages..."
for ($i = 1; $i -le 10; $i++) {
    Write-Progress $i 10 "Installing package $i of 10"
    Start-Sleep -Milliseconds 200
}

# Step 5: Sections with icons
Write-Step 5 "Testing sections with different icons"
Write-Section "Package Installation" $script:Icons.Package
Write-Section "System Configuration" $script:Icons.Config
Write-Section "Windows Features" $script:Icons.Windows
Write-Section "PowerShell Modules" $script:Icons.PowerShell

# Step 6: Administrator check
Write-Step 6 "Testing administrator privileges"
if (Test-IsAdministrator) {
    Write-Success "Running with administrator privileges"
} else {
    Write-Warning "Not running as administrator"
}

# Step 7: Time tracking
Write-Step 7 "Testing time tracking"
Measure-ActionTime "Sleep operation" { Start-Sleep -Seconds 2 }
Measure-ActionTime "Quick operation" { Write-Host "This is fast" }

# Step 8: Package installation simulation
Write-Step 8 "Testing package installation simulation"
$packages = @("Git.Git", "Microsoft.PowerShell", "7zip.7zip")

# Simulate package installation with mock options
$mockOptions = @{ Silent = $true }
Write-Info "Simulating Winget package installation..."

$failed = @()
for ($i = 0; $i -lt $packages.Count; $i++) {
    $package = $packages[$i]
    Write-Progress ($i + 1) $packages.Count "Simulating installation: $package"

    # Simulate random success/failure for demonstration
    $random = Get-Random -Minimum 1 -Maximum 10
    if ($random -le 8) {
        # Simulate success
        Start-Sleep -Milliseconds 500
    } else {
        # Simulate failure
        $failed += $package
        Write-Warning "Simulated failure for package: $package"
    }
}

if ($failed.Count -eq 0) {
    Write-Success "All packages would be installed successfully (simulation)"
} else {
    Write-Warning "Some packages would fail: $($failed -join ', ') (simulation)"
}

# Step 9: Windows version check
Write-Step 9 "Testing Windows version check"
if (Test-WindowsVersion "10.0.0.0") {
    Write-Success "Windows version check passed"
} else {
    Write-Warning "Windows version check failed"
}

# Custom banner demonstration
Write-Host ""
Write-Banner "Custom Banner" $script:Icons.Success $script:Colors.Green $script:Colors.Green

# Final footer with summary
Write-Footer "PowerShell Formatting Test" "completed"

# Additional information
Write-Host ""
Write-Info "Test completed! Check the output above to see all formatting options."
Write-Info "This script can be used as a reference for implementing formatting in other scripts."
