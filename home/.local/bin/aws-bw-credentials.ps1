# AWS Credential Process Script for PowerShell
# Usage: aws-bw-credentials.ps1 <bw-item-name>

param(
    [Parameter(Mandatory=$true)]
    [string]$BWItemName
)

$ErrorActionPreference = "Stop"

try {
    # Check for Bitwarden session
    if (-not $env:BW_SESSION) {
        Write-Error "BW_SESSION environment variable not set. Please run: `$env:BW_SESSION = bw unlock --raw"
        exit 1
    }

    # Fetch credentials using BW CLI
    $accessKey = bw get username "$BWItemName" --session $env:BW_SESSION
    $secretKey = bw get password "$BWItemName" --session $env:BW_SESSION

    if (-not $accessKey -or -not $secretKey) {
        Write-Error "Failed to retrieve AWS credentials from Bitwarden item: $BWItemName"
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
