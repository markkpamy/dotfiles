# Windows PowerShell Weather Script
# Similar to the weather.sh script in the Linux dotfiles

param(
    [string]$Location,
    [string]$Units = "",
    [switch]$Help,
    [switch]$Moon
)

function Show-Help {
    Write-Host "Weather - PowerShell Edition"
    Write-Host "Description: Provides a 3-day forecast for your current location or a specified location."
    Write-Host "  With no parameters, Weather will default to your current location."
    Write-Host ""
    Write-Host "Usage: .\Get-Weather.ps1 [parameters]"
    Write-Host "Parameters:"
    Write-Host "  -Location <city/country> : Get weather for the specified location"
    Write-Host "  -Units m                 : Get weather in metric units"
    Write-Host "  -Units i                 : Get weather in imperial units"
    Write-Host "  -Moon                    : Get the current moon phase"
    Write-Host "  -Help                    : Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\Get-Weather.ps1"
    Write-Host "  .\Get-Weather.ps1 -Location 'Paris'"
    Write-Host "  .\Get-Weather.ps1 -Location 'Tokyo' -Units m"
    Write-Host "  .\Get-Weather.ps1 -Moon"
}

function Test-Internet {
    try {
        $testConnection = Test-NetConnection -ComputerName "wttr.in" -Port 443 -WarningAction SilentlyContinue
        return $testConnection.TcpTestSucceeded
    }
    catch {
        return $false
    }
}

function Get-IPLocation {
    try {
        $ipInfo = Invoke-RestMethod -Uri "https://ipinfo.io/json" -TimeoutSec 10
        return $ipInfo
    }
    catch {
        Write-Error "Failed to get location from IP: $_"
        return $null
    }
}

function Get-WeatherForIP {
    param($UnitsParam)

    $ipInfo = Get-IPLocation

    if ($null -eq $ipInfo) {
        return "Could not determine your location."
    }

    if ($ipInfo.country -eq "US") {
        $locationQuery = "$($ipInfo.city),$($ipInfo.region)"
    }
    else {
        $locationQuery = "$($ipInfo.loc)"
    }

    $url = "https://wttr.in/$locationQuery$UnitsParam"

    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        return $response.Content
    }
    catch {
        return "Failed to get weather: $_"
    }
}

function Get-WeatherForLocation {
    param($LocationParam, $UnitsParam)

    $locationQuery = $LocationParam -replace " ", "+"
    $url = "https://wttr.in/$locationQuery$UnitsParam"

    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        return $response.Content
    }
    catch {
        return "Failed to get weather for $LocationParam`: $_"
    }
}

# Main execution

if ($Help) {
    Show-Help
    exit 0
}

if (-not (Test-Internet)) {
    Write-Error "Error: No active internet connection."
    exit 1
}

# Determine units parameter
$unitsParam = ""
if ($Units -eq "m") {
    $unitsParam = "?m"
}
elseif ($Units -eq "i") {
    $unitsParam = "?u"
}

# Get moon phase if requested
if ($Moon) {
    $result = Get-WeatherForLocation "Moon" ""
    Write-Output $result
    exit 0
}

# Either get weather for specified location or for current IP
if ($Location) {
    $result = Get-WeatherForLocation $Location $unitsParam
}
else {
    $result = Get-WeatherForIP $unitsParam
}

Write-Output $result
