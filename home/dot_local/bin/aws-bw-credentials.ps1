# AWS Credential Process Script for PowerShell
# Usage: aws-bw-credentials.ps1 <bw-item-name>

param(
    [Parameter(Mandatory=$true)]
    [string]$BWItemName
)

$ErrorActionPreference = "Stop"

# Suppress all output except the final JSON to stderr
$ProgressPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'
$InformationPreference = 'SilentlyContinue'

try {
    # Check for Bitwarden session - try environment variable first, then session file
    $session = $env:BW_SESSION
    if (-not $session) {
        $sessionFile = "$env:USERPROFILE\.config\bitwarden-utils\session"
        if (Test-Path $sessionFile) {
            $session = Get-Content $sessionFile -Raw
            $session = $session.Trim()
        }
    }

    if (-not $session) {
        Write-Host "No Bitwarden session found. Please run: bwu" -ForegroundColor Red | Out-Host
        exit 1
    }

    # Fetch credentials using BW CLI
    $accessKey = bw get username "$BWItemName" --session $session 2>$null
    $secretKey = bw get password "$BWItemName" --session $session 2>$null

    if (-not $accessKey -or -not $secretKey) {
        Write-Host "Failed to retrieve AWS credentials from Bitwarden item: $BWItemName" -ForegroundColor Red | Out-Host
        exit 1
    }

    $credential = @{
        Version = 1
        AccessKeyId = $accessKey
        SecretAccessKey = $secretKey
    }

    $credential | ConvertTo-Json -Compress
}
catch {
    Write-Error "Error retrieving AWS credentials: $($_.Exception.Message)"
    exit 1
}
