# PowerShell script to install Bitwarden Secrets Manager CLI on Windows
# and configure it to use EU servers

# Ensure script stops on errors
$ErrorActionPreference = "Stop"

# Constants
$LogFile = "$env:TEMP\bws-install.log"
$TempDir = Join-Path $env:TEMP "bws-install-$(Get-Random)"
$InstallDir = "$env:USERPROFILE\.local\bin"
$ConfigDir = "$env:USERPROFILE\.config\bws"

# Create directories if they don't exist
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

# Function to log messages
function Write-Log {
  param (
    [Parameter(Mandatory=$true)]
    [string]$Message
  )

  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $logMessage = "[$timestamp] $Message"
  Write-Host $logMessage
  Add-Content -Path $LogFile -Value $logMessage
}

# Function to get the latest version of Bitwarden Secrets Manager CLI
function Get-LatestVersion {
  Write-Log "Fetching latest version information..."

  try {
#    $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/bitwarden/sdk/releases/latest"
#    $version = $releaseInfo.tag_name -replace 'bws-v', ''
    $version = "1.0.0"
    Write-Log "Latest version: $version"
    return $version
  }
  catch {
    Write-Log "Error fetching version information: $_"
    throw "Failed to fetch latest version information. Check your internet connection."
  }
}

# Function to download and install Bitwarden Secrets Manager CLI
function Install-Bws {
  param (
    [Parameter(Mandatory=$true)]
    [string]$Version
  )

  Write-Log "Preparing to install Bitwarden Secrets Manager CLI v$Version..."

  # Determine architecture
  $arch = "x86_64"
  if ([Environment]::Is64BitOperatingSystem -eq $false) {
    Write-Log "Error: 32-bit Windows is not supported by Bitwarden Secrets Manager CLI."
    throw "32-bit Windows is not supported."
  }

  # Set the download URL
#  bws-x86_64-pc-windows-msvc-1.0.0.zip

  $fileName="bws-$ARCH-pc-windows-msvc-$Version.zip"
  $downloadUrl = "https://github.com/bitwarden/sdk/releases/download/bws-v$Version/$fileName"
  $zipPath = Join-Path $TempDir $fileName

  # Download the ZIP file
  Write-Log "Downloading from $downloadUrl..."
  try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath
  }
  catch {
    Write-Log "Error downloading file: $_"
    throw "Failed to download Bitwarden Secrets Manager CLI."
  }

  # Extract the ZIP file
  Write-Log "Extracting files..."
  try {
    Expand-Archive -Path $zipPath -DestinationPath $TempDir -Force
  }
  catch {
    Write-Log "Error extracting ZIP file: $_"
    throw "Failed to extract ZIP file."
  }

  # Copy files to installation directory
  Write-Log "Installing to $InstallDir..."
  try {
    Copy-Item -Path "$TempDir\bws.exe" -Destination $InstallDir -Force
  }
  catch {
    Write-Log "Error copying files: $_"
    throw "Failed to copy files to installation directory."
  }

  # Add to PATH if not already present
  Add-ToPath
}

# Function to add installation directory to PATH
function Add-ToPath {
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")

  if ($userPath -notlike "*$InstallDir*") {
    Write-Log "Adding to user PATH environment variable..."

    try {
      $newPath = "$userPath;$InstallDir"
      [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
      # Also update the current session's PATH
      $env:Path = "$env:Path;$InstallDir"
      Write-Log "Added to PATH successfully."
    }
    catch {
      Write-Log "Error adding to PATH: $_"
      Write-Log "Warning: You may need to add '$InstallDir' to your PATH manually."
    }
  }
  else {
    Write-Log "Installation directory is already in PATH."
  }
}

# Function to create the configuration file
function Create-ConfigFile {
  $configFilePath = Join-Path $ConfigDir "config"

  Write-Log "Creating configuration file at $configFilePath..."

  $configContent = @"
[profiles.default]
server_api = "https://api.bitwarden.eu"
server_identity = "https://identity.bitwarden.eu"
"@

  try {
    Set-Content -Path $configFilePath -Value $configContent
    Write-Log "Configuration file created successfully."
  }
  catch {
    Write-Log "Error creating configuration file: $_"
    throw "Failed to create configuration file."
  }
}

# Function to verify installation
function Verify-Installation {
  Write-Log "Verifying installation..."

  try {
    $output = & "$InstallDir\bws.exe" --version
    Write-Log "Bitwarden Secrets Manager CLI installed successfully: $output"
    return $true
  }
  catch {
    Write-Log "Error verifying installation: $_"
    return $false
  }
}

# Function to clean up temporary files
function Clean-Up {
  Write-Log "Cleaning up temporary files..."

  try {
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "Cleanup completed."
  }
  catch {
    Write-Log "Warning: Failed to clean up some temporary files: $_"
  }
}

# Main execution
try {
  Write-Log "=== Bitwarden Secrets Manager CLI Installation Started ==="

  # Get latest version
  $version = Get-LatestVersion

  # Install BWS
  Install-Bws -Version $version

  # Create configuration file
  Create-ConfigFile

  # Verify installation
  if (Verify-Installation) {
    Write-Log "=== Installation Completed Successfully ==="
    Write-Log "The Bitwarden Secrets Manager CLI has been installed to: $InstallDir"
    Write-Log "Configuration has been set to use Bitwarden EU servers."
    Write-Log "You may need to restart your terminal or PowerShell session to use the 'bws' command."
    Write-Log "For more information, visit: https://bitwarden.com/help/secrets-manager-cli/"
  }
  else {
    Write-Log "=== Installation Verification Failed ==="
    Write-Log "The CLI may not work correctly. Please check the log file for errors: $LogFile"
  }
}
catch {
  Write-Log "=== Installation Failed ==="
  Write-Log "Error: $_"
}
finally {
  # Always clean up
  Clean-Up
}
