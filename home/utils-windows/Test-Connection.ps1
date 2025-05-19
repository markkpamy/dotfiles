# Windows PowerShell Network Connectivity Checker
# Similar to the am-i-online.sh script in the Linux dotfiles

param(
    [switch]$Detailed
)

# Define colors for output
$colorSuccess = "Green"
$colorFailure = "Red"
$colorInfo = "Cyan"
$colorGeneral = "White"

# Create horizontal line
function Write-HorizontalLine {
    Write-Host "─────────────────────────" -ForegroundColor $colorInfo
}

# Test DNS resolution
function Test-DnsResolution {
    try {
        $result = Resolve-DnsName -Name "google.com" -Type A -ErrorAction Stop
        if ($result) {
            Write-Host "  ✅ DNS Resolution: " -NoNewline -ForegroundColor $colorSuccess
            Write-Host "Working" -ForegroundColor $colorGeneral
            return $true
        }
    } catch {
        Write-Host "  ❌ DNS Resolution: " -NoNewline -ForegroundColor $colorFailure
        Write-Host "Failed" -ForegroundColor $colorGeneral
        return $false
    }
}

# Test default gateway connectivity
function Test-DefaultGateway {
    try {
        $gateway = (Get-NetRoute | Where-Object { $_.DestinationPrefix -eq "0.0.0.0/0" } | Sort-Object RouteMetric | Select-Object -First 1).NextHop

        if ($gateway) {
            $pingResult = Test-NetConnection -ComputerName $gateway -WarningAction SilentlyContinue
            if ($pingResult.PingSucceeded) {
                Write-Host "  ✅ Default Gateway ($gateway): " -NoNewline -ForegroundColor $colorSuccess
                Write-Host "Reachable" -ForegroundColor $colorGeneral
                return $true
            } else {
                Write-Host "  ❌ Default Gateway ($gateway): " -NoNewline -ForegroundColor $colorFailure
                Write-Host "Unreachable" -ForegroundColor $colorGeneral
                return $false
            }
        } else {
            Write-Host "  ❌ Default Gateway: " -NoNewline -ForegroundColor $colorFailure
            Write-Host "Not found" -ForegroundColor $colorGeneral
            return $false
        }
    } catch {
        Write-Host "  ❌ Default Gateway: " -NoNewline -ForegroundColor $colorFailure
        Write-Host "Error checking" -ForegroundColor $colorGeneral
        return $false
    }
}

# Test internet connectivity
function Test-InternetAccess {
    param($Site = "1.1.1.1")

    try {
        $result = Test-NetConnection -ComputerName $Site -WarningAction SilentlyContinue
        if ($result.PingSucceeded) {
            Write-Host "  ✅ Internet Access: " -NoNewline -ForegroundColor $colorSuccess
            Write-Host "Connected" -ForegroundColor $colorGeneral
            return $true
        } else {
            Write-Host "  ❌ Internet Access: " -NoNewline -ForegroundColor $colorFailure
            Write-Host "Disconnected" -ForegroundColor $colorGeneral
            return $false
        }
    } catch {
        Write-Host "  ❌ Internet Access: " -NoNewline -ForegroundColor $colorFailure
        Write-Host "Error checking" -ForegroundColor $colorGeneral
        return $false
    }
}

# Test HTTP connectivity
function Test-HttpConnectivity {
    try {
        $request = Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($request.StatusCode -eq 200) {
            Write-Host "  ✅ Web Connectivity: " -NoNewline -ForegroundColor $colorSuccess
            Write-Host "Working" -ForegroundColor $colorGeneral
            return $true
        } else {
            Write-Host "  ❌ Web Connectivity: " -NoNewline -ForegroundColor $colorFailure
            Write-Host "Status code $($request.StatusCode)" -ForegroundColor $colorGeneral
            return $false
        }
    } catch {
        Write-Host "  ❌ Web Connectivity: " -NoNewline -ForegroundColor $colorFailure
        Write-Host "Failed" -ForegroundColor $colorGeneral
        return $false
    }
}

# Test network adapters
function Test-NetworkAdapters {
    $activeAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

    if ($activeAdapters.Count -gt 0) {
        Write-Host "  ✅ Network Adapters: " -NoNewline -ForegroundColor $colorSuccess
        Write-Host "$($activeAdapters.Count) active" -ForegroundColor $colorGeneral

        if ($Detailed) {
            foreach ($adapter in $activeAdapters) {
                $ipConfig = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4
                Write-Host "     - $($adapter.Name): $($adapter.InterfaceDescription)" -ForegroundColor $colorGeneral
                Write-Host "       IP: $($ipConfig.IPAddress), Speed: $($adapter.LinkSpeed)" -ForegroundColor $colorGeneral
            }
        }
        return $true
    } else {
        Write-Host "  ❌ Network Adapters: " -NoNewline -ForegroundColor $colorFailure
        Write-Host "No active adapters" -ForegroundColor $colorGeneral
        return $false
    }
}

# Main execution
Write-HorizontalLine
Write-Host "📶 Checking network connectivity..." -ForegroundColor $colorInfo
Write-HorizontalLine

$adapterStatus = Test-NetworkAdapters
$gatewayStatus = Test-DefaultGateway
$dnsStatus = Test-DnsResolution
$internetStatus = Test-InternetAccess
$webStatus = Test-HttpConnectivity

Write-HorizontalLine

# Determine overall status
$overallStatus = $adapterStatus -and $gatewayStatus -and $dnsStatus -and $internetStatus -and $webStatus

if ($overallStatus) {
    Write-Host "✅ Overall Status: " -NoNewline -ForegroundColor $colorSuccess
    Write-Host "ONLINE" -ForegroundColor $colorGeneral
} else {
    Write-Host "❌ Overall Status: " -NoNewline -ForegroundColor $colorFailure
    Write-Host "ISSUES DETECTED" -ForegroundColor $colorGeneral
}

Write-HorizontalLine

# Return exit code based on connectivity status
exit ([int](-not $overallStatus))
