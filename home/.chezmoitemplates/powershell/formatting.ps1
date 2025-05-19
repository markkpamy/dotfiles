# Chezmoi PowerShell Script Formatting Library
# Import this module in your PowerShell scripts for consistent formatting

# ANSI Color codes for PowerShell
$script:Colors = @{
    Red = "`e[0;31m"
    Green = "`e[0;32m"
    Yellow = "`e[1;33m"
    Blue = "`e[0;34m"
    Purple = "`e[0;35m"
    Cyan = "`e[0;36m"
    White = "`e[1;37m"
    Gray = "`e[0;90m"
    NC = "`e[0m"  # No Color
    Bold = "`e[1m"
    Dim = "`e[2m"
}

# Icons
$script:Icons = @{
    Success = "✅"
    Error = "❌"
    Warning = "⚠️"
    Info = "ℹ️"
    Package = "📦"
    Download = "⬇️"
    Install = "🔧"
    Config = "⚙️"
    Check = "🔍"
    Arrow = "▶"
    Time = "⏱️"
    Summary = "🏁"
    Update = "🔄"
    Windows = "🪟"
    PowerShell = "💙"
    Scoop = "🪣"
    Choco = "🍫"
    Python = "🐍"
    Node = "📗"
}

# Box drawing characters
$script:Box = @{
    Top = "┌"
    Bottom = "└"
    Side = "│"
    Horizontal = "─"
}

# Global variables for tracking
$script:ScriptStartTime = Get-Date
$script:TotalSteps = 0
$script:CurrentStep = 0
$script:FailedSteps = 0
$script:SkippedSteps = 0

function Write-Banner {
    param(
        [string]$Message,
        [string]$Icon = "",
        [string]$Color = $script:Colors.Purple,
        [string]$BorderColor = $script:Colors.Purple,
        [int]$Width = 80
    )

    if ($Icon) {
        $Message = "$Icon $Message"
    }

    $MessageLength = $Message.Length
    $Padding = [math]::Max(0, [math]::Floor(($Width - $MessageLength - 4) / 2))

    $HorizontalLine = $script:Box.Horizontal * ($Width - 2)
    Write-Host "$BorderColor$($script:Box.Top)$HorizontalLine$($script:Box.Top)$($script:Colors.NC)"
    Write-Host "$BorderColor$($script:Box.Side)$($script:Colors.NC) $(' ' * $Padding)$Color$Message$($script:Colors.NC)$(' ' * $Padding) $BorderColor$($script:Box.Side)$($script:Colors.NC)"
    Write-Host "$BorderColor$($script:Box.Bottom)$HorizontalLine$($script:Box.Bottom)$($script:Colors.NC)"
}

function Write-Section {
    param(
        [string]$Title,
        [string]$Icon = "",
        [string]$Color = $script:Colors.Blue
    )

    Write-Host ""
    if ($Icon) {
        $Title = "$Icon $Title"
    }
    Write-Host "$Color$($script:Colors.Bold)$($script:Box.Horizontal)$($script:Box.Horizontal)$($script:Box.Horizontal) $Title $($script:Box.Horizontal)$($script:Box.Horizontal)$($script:Box.Horizontal)$($script:Colors.NC)"
    Write-Host ""
}

function Write-Step {
    param(
        [int]$Step,
        [string]$Description,
        [string]$Color = $script:Colors.White
    )

    $script:CurrentStep = $Step
    Write-Host "$Color$($script:Colors.Bold)$($script:Icons.Arrow) Step $Step`:$($script:Colors.NC) $Description"
}

function Write-Action {
    param(
        [string]$Action,
        [string]$Item,
        [string]$Icon = $script:Icons.Install,
        [string]$Color = $script:Colors.Yellow
    )

    Write-Host "  $Color$Icon $Action`:$($script:Colors.NC) $($script:Colors.Gray)$Item$($script:Colors.NC)"
}

function Write-Success {
    param([string]$Message)
    Write-Host "$($script:Colors.Green)$($script:Icons.Success) $Message$($script:Colors.NC)"
}

function Write-ErrorFormatted {
    param([string]$Message)
    Write-Host "$($script:Colors.Red)$($script:Icons.Error) $Message$($script:Colors.NC)"
    $script:FailedSteps++
}

function Write-Warning {
    param([string]$Message)
    Write-Host "$($script:Colors.Yellow)$($script:Icons.Warning) $Message$($script:Colors.NC)"
}

function Write-Info {
    param([string]$Message)
    Write-Host "$($script:Colors.Cyan)$($script:Icons.Info) $Message$($script:Colors.NC)"
}

function Write-Skipped {
    param([string]$Message)
    Write-Host "$($script:Colors.Yellow)$($script:Icons.Warning) $Message$($script:Colors.NC)"
    $script:SkippedSteps++
}

function Write-Progress {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Description
    )

    $Percent = [math]::Floor(($Current * 100) / $Total)
    $Filled = [math]::Floor($Percent / 5)
    $Empty = 20 - $Filled

    $ProgressBar = "$($script:Colors.Green)" + ("█" * $Filled) + "$($script:Colors.Gray)" + ("░" * $Empty)

    Write-Host -NoNewline "`r$($script:Colors.Cyan)Progress: [$ProgressBar$($script:Colors.Cyan)] $Percent% - $($script:Colors.White)$Description$($script:Colors.NC)"

    if ($Current -eq $Total) {
        Write-Host ""
    }
}

function Test-CommandAvailable {
    param(
        [string]$Command,
        [string]$Name = $Command
    )

    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        Write-Success "$Name is available"
        return $true
    } else {
        Write-ErrorFormatted "$Name is not available"
        return $false
    }
}

function Test-RequiredCommands {
    param([string[]]$Commands)

    $Missing = @()
    foreach ($Command in $Commands) {
        if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
            $Missing += $Command
        }
    }

    if ($Missing.Count -gt 0) {
        Write-ErrorFormatted "Missing required commands: $($Missing -join ', ')"
        Write-Info "Please install the missing commands and run this script again"
        return $false
    }

    Write-Success "All required commands are available"
    return $true
}

function Write-Header {
    param(
        [string]$ScriptName,
        [string]$Description,
        [string]$Icon = $script:Icons.Package
    )

    Write-Host ""
    Write-Banner $ScriptName $Icon
    Write-Host "$($script:Colors.Gray)$Description$($script:Colors.NC)"
    Write-Host ""
}

function Write-Footer {
    param(
        [string]$ScriptName,
        [string]$Status = "completed"
    )

    $EndTime = Get-Date
    $Duration = $EndTime - $script:ScriptStartTime

    Write-Host ""
    Write-Section "Summary" $script:Icons.Summary

    if ($Status -eq "completed") {
        Write-Success "$ScriptName completed successfully!"
    } else {
        Write-ErrorFormatted "$ScriptName failed!"
    }

    # Format duration
    if ($Duration.TotalMinutes -ge 1) {
        Write-Info "Total execution time: $([math]::Floor($Duration.TotalMinutes))m $($Duration.Seconds)s"
    } else {
        Write-Info "Total execution time: $([math]::Floor($Duration.TotalSeconds))s"
    }

    # Print step summary if steps were tracked
    if ($script:TotalSteps -gt 0) {
        $SuccessfulSteps = $script:TotalSteps - $script:FailedSteps - $script:SkippedSteps
        Write-Info "Steps completed: $SuccessfulSteps/$($script:TotalSteps)"
        if ($script:FailedSteps -gt 0) { Write-ErrorFormatted "Failed steps: $($script:FailedSteps)" }
        if ($script:SkippedSteps -gt 0) { Write-Warning "Skipped steps: $($script:SkippedSteps)" }
    }

    Write-Host ""
}

function Set-TotalSteps {
    param([int]$Total)
    $script:TotalSteps = $Total
}

function Measure-ActionTime {
    param(
        [string]$Description,
        [scriptblock]$Action
    )

    $StartTime = Get-Date
    try {
        & $Action
        $EndTime = Get-Date
        $Duration = ($EndTime - $StartTime).TotalSeconds
        Write-Info "$Description completed in $([math]::Round($Duration, 1))s"
        return $true
    } catch {
        $EndTime = Get-Date
        $Duration = ($EndTime - $StartTime).TotalSeconds
        Write-ErrorFormatted "$Description failed after $([math]::Round($Duration, 1))s"
        Write-ErrorFormatted "Error: $($_.Exception.Message)"
        return $false
    }
}

function Install-PackagesSafely {
    param(
        [string]$PackageManager,
        [string[]]$Packages,
        [hashtable]$ManagerOptions = @{}
    )

    $Total = $Packages.Count
    Write-Info "Installing $Total packages using $PackageManager..."

    $Failed = @()
    for ($i = 0; $i -lt $Packages.Count; $i++) {
        $Package = $Packages[$i]
        Write-Progress ($i + 1) $Total "Installing: $Package"

        try {
            switch ($PackageManager.ToLower()) {
                "winget" {
                    $Args = @("install", $Package, "--accept-source-agreements", "--accept-package-agreements")
                    if ($ManagerOptions.Silent) { $Args += "--silent" }
                    & winget @Args | Out-Null
                }
                "scoop" {
                    & scoop install $Package | Out-Null
                }
                "choco" {
                    $Args = @("install", $Package, "-y")
                    if ($ManagerOptions.Force) { $Args += "--force" }
                    & choco @Args | Out-Null
                }
                default {
                    throw "Unknown package manager: $PackageManager"
                }
            }
        } catch {
            Write-Warning "Failed to install $Package`: $($_.Exception.Message)"
            $Failed += $Package
        }
    }

    if ($Failed.Count -eq 0) {
        Write-Success "All packages installed successfully"
    } else {
        Write-Warning "Failed to install $($Failed.Count) packages: $($Failed -join ', ')"
    }

    return ($Failed.Count -eq 0)
}

function Test-IsAdministrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-AdminPrivileges {
    if (-not (Test-IsAdministrator)) {
        Write-Warning "This script requires administrator privileges"
        Write-Info "Attempting to restart with elevated permissions..."

        try {
            Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs -Wait
            exit 0
        } catch {
            Write-ErrorFormatted "Failed to elevate privileges: $($_.Exception.Message)"
            Write-Info "Please run this script as Administrator"
            return $false
        }
    }

    Write-Success "Running with administrator privileges"
    return $true
}

function Test-WindowsVersion {
    param([string]$MinimumVersion = "10.0.0.0")

    $CurrentVersion = [System.Environment]::OSVersion.Version
    $MinVersion = [Version]$MinimumVersion

    if ($CurrentVersion -ge $MinVersion) {
        Write-Success "Windows version $($CurrentVersion.ToString()) meets requirements"
        return $true
    } else {
        Write-ErrorFormatted "Windows version $($CurrentVersion.ToString()) is below minimum requirement $MinimumVersion"
        return $false
    }
}

# Initialize error action preference for better error handling
$ErrorActionPreference = "Stop"

# Export functions (for module usage)
Export-ModuleMember -Function *
