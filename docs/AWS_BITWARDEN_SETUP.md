# AWS + Bitwarden CLI Setup Guide

Simple AWS authentication using Bitwarden CLI with explicit BW item names for different credential sets.

## Setup Steps

### 1. Create Bitwarden Items

Create 2 BW items for your AWS credentials:

```bash
# For default/non-NX profiles
bw create item '{
  "object": "item",
  "type": 1,
  "name": "AWS-Default",
  "login": {
    "username": "XXXXXXXXXX",
    "password": "XXXXXXXXXXXXXXXX"
  },
  "notes": "AWS credentials for default and non-NX profiles"
}'

# For NX profiles  
bw create item '{
  "object": "item",
  "type": 1,
  "name": "AWS-NX",
  "login": {
    "username": "XXXXXXXXXXXXXXXXXXX",
    "password": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  },
  "notes": "AWS credentials for all NX-related profiles"
}'
```

### 2. Verify BW Items Created

```bash
# Check items exist
bw list items --search "AWS-Default"
bw list items --search "AWS-NX"
```

### 3. Deploy Configuration

```bash
cd ~/dotfiles
chezmoi apply
```

### 4. Set Up Bitwarden Session

```bash
# Unlock Bitwarden and set session
export BW_SESSION=$(bw unlock --raw)

# Or use your existing bw helper functions if available
```

### 5. Test the Integration

```bash
# Test default credentials
aws sts get-caller-identity --profile default

# Test NX credentials via nx_base
aws sts get-caller-identity --profile nx_base

# Test NX role profiles
aws sts get-caller-identity --profile nx_training_advanced
aws-profiles
```

## How It Works

### File Structure
The implementation uses these key files:
- **`home/dot_aws/config.tmpl`** - AWS configuration template
- **`home/dot_local/bin/executable_aws-bw-credentials`** - Unix credential script
- **`home/dot_local/bin/aws-bw-credentials.ps1`** - PowerShell credential script
- **`home/.chezmoidata/aws.yml`** - AWS configuration data
- **`home/.chezmoidata/global.yml`** - Bitwarden configuration

### Credential Mapping
- **Default profiles**: Use `credential_process = aws-bw-credentials "AWS-Default"`
- **NX base profile**: Use `credential_process = aws-bw-credentials "AWS-NX"`
- **All NX role profiles**: Use `source_profile = nx_base` (inherits NX credentials)

### Profile Structure
```ini
# Default profile uses AWS-Default item
[default]
credential_process = /home/user/.local/bin/aws-bw-credentials "AWS-Default"

# NX base profile uses AWS-NX item  
[profile nx_base]
credential_process = /home/user/.local/bin/aws-bw-credentials "AWS-NX"

# NX role profiles inherit from nx_base
[profile nx_training_advanced]
source_profile = nx_base  # Uses AWS-NX credentials
role_arn = arn:aws:iam::766272829042:role/nx-training-advanced

[profile nx_datahub_advanced]
source_profile = nx_base  # Uses AWS-NX credentials
role_arn = arn:aws:iam::261001339617:role/nx-datahub-advanced
```

### Cross-Platform Support
- **Linux/macOS**: Uses `~/.local/bin/aws-bw-credentials` (Bash script)
- **Windows**: Uses PowerShell script `aws-bw-credentials.ps1`
- **Automatic detection**: Chezmoi templates handle OS-specific paths

## Available Commands

All your existing AWS helper functions work:

### Profile Management
- `aws-profile [name]` - Switch profiles or show current
- `aws-profiles` - Show all profiles dynamically from actual config
- `aws-config-update` - Refresh config (re-applies Chezmoi templates)

## Usage Examples

```bash
# Default credentials (uses AWS-Default BW item)
aws s3 ls --profile default
aws sts get-caller-identity --profile default

# NX base credentials (uses AWS-NX BW item directly)
aws sts get-caller-identity --profile nx_base

# NX role profiles (uses AWS-NX BW item via nx_base)
aws s3 ls --profile nx_training_advanced
aws ec2 describe-instances --profile nx_datahub_master
aws sts get-caller-identity --profile nx-presales-advanced

# Quick profile switching
aws-dev && aws s3 ls     # Switch to nx_training_advanced
aws-prod && aws ec2 describe-instances   # Switch to nx_training_master
```

## Configuration Details

### AWS Configuration (`aws.yml`)
```yaml
aws:
  enabled: true
  default_region: 'eu-west-3'
  default_output: 'json'
  use_bws: false  # Use traditional BW CLI
```

### Bitwarden Configuration (`global.yml`)
```yaml
bitwarden:
  enabled: true
  # ... existing config ...
  aws:
    item_name: 'AWS Default Profile'  # Not used with new approach
```

## Troubleshooting

### "BW_SESSION not set"
```bash
# Check session status
bw status

# Unlock and set session
export BW_SESSION=$(bw unlock --raw)

# Verify session works
bw list items --search "AWS"
```

### "Failed to retrieve credentials from item"
```bash
# Verify BW item exists and name matches exactly
bw list items --search "AWS-Default"
bw list items --search "AWS-NX"

# Test BW access directly
bw get username "AWS-Default" --session $BW_SESSION
bw get username "AWS-NX" --session $BW_SESSION
```

### "credential_process failed"
```bash
# Test script directly
~/.local/bin/aws-bw-credentials "AWS-Default"
~/.local/bin/aws-bw-credentials "AWS-NX"

# Check script permissions
ls -la ~/.local/bin/aws-bw-credentials
chmod +x ~/.local/bin/aws-bw-credentials

# Verify file paths in AWS config
grep credential_process ~/.aws/config
```

### "Profile nx_base not found"
```bash
# Re-apply Chezmoi templates
chezmoi apply ~/.aws/config

# Check generated config
cat ~/.aws/config | grep -A5 "nx_base"
```

### Region/Format Issues
```bash
# Check current region setting
aws configure get region --profile nx_base
aws configure get region --profile default

# Test with explicit region
aws sts get-caller-identity --profile nx_base --region eu-west-3
```

## Security Benefits

✅ **Explicit credential mapping** - Clear which BW item each profile uses  
✅ **Only 2 BW items** to manage (AWS-Default, AWS-NX)  
✅ **No hardcoded credentials** anywhere in configuration files  
✅ **Separate credential sets** for different AWS accounts  
✅ **All existing profiles preserved** - just new secure credential sources  
✅ **Cross-platform compatibility** - works on Windows, Linux, macOS  
✅ **Bitwarden session security** - Credentials only available when unlocked  
✅ **Role-based access** - NX roles inherit from secure base credentials

## Additional Profiles

Your configuration also includes SSO profiles that remain unchanged:

```ini
[profile mk_root_admin]
sso_session = sso
sso_account_id = 409348746500
sso_role_name = AdministratorAccess

[profile mk_sandbox_admin]
sso_session = sso
sso_account_id = 347264101318
sso_role_name = AdministratorAccess
```

These continue to work as before using AWS SSO authentication.
