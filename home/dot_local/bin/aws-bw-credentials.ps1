# AWS Credential Process Script for PowerShell
# Usage: aws-bw-credentials.ps1 <bw-item-name>

param(
    [Parameter(Mandatory=$true)]
    [string]$BWItemName
)

$ErrorActionPreference = "Stop"

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
        Write-Error "No Bitwarden session found. Please run: bwu"
        exit 1
    }

    # Fetch credentials using BW CLI
    $accessKey = bw get username "$BWItemName" --session $session
    $secretKey = bw get password "$BWItemName" --session $session

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
