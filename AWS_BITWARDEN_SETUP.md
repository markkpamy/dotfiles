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

### 2. Deploy Configuration

```bash
cd ~/dotfiles
chezmoi apply
```

### 3. Set Up Bitwarden Session

```bash
# Unlock Bitwarden and set session
export BW_SESSION=$(bw unlock --raw)

# Or use your existing helper if available
bw-unlock
```

### 4. Test the Integration

```bash
# Test default credentials
aws sts get-caller-identity --profile default

# Test NX credentials
aws sts get-caller-identity --profile nx_training_advanced

# Test all profiles
aws-test
```

## How It Works

### Credential Mapping
- **Default profiles**: Use `credential_process = aws-bw-credentials "AWS-Default"`
- **NX base profile**: Use `credential_process = aws-bw-credentials "AWS-NX"`
- **All NX role profiles**: Use `source_profile = nx_base` (inherits NX credentials)

### Profile Structure
```ini
# Default profiles use AWS-Default item
[default]
credential_process = aws-bw-credentials "AWS-Default"

# NX base profile uses AWS-NX item  
[profile nx_base]
credential_process = aws-bw-credentials "AWS-NX"

# NX role profiles inherit from nx_base
[profile nx_training_advanced]
source_profile = nx_base  # Uses AWS-NX credentials
```

## Available Commands

All your existing AWS helper functions work:

### Profile Management
- `aws-profile [name]` - Switch profiles or show current
- `aws-test` - Test AWS configuration
- `aws-profiles` - Show all profiles dynamically
- `aws-dev`, `aws-prod`, etc. - Quick profile switching

### Configuration Management  
- `aws-config-update` - Refresh config (re-applies Chezmoi)

## Usage Examples

```bash
# Default credentials (uses AWS-Default BW item)
aws s3 ls --profile default

# NX credentials (uses AWS-NX BW item via nx_base)
aws s3 ls --profile nx_training_advanced
aws ec2 describe-instances --profile nx_datahub_master
aws sts get-caller-identity --profile nx-presales-advanced

# Quick profile switching
aws-dev     # nx_training_advanced
aws-prod    # nx_training_master  
aws-datahub # nx_datahub_master
```

## Troubleshooting

### "BW_SESSION not set"
Run: `export BW_SESSION=$(bw unlock --raw)`

### "Failed to retrieve credentials from item"
- Verify BW item exists: `bw list items --search "AWS-Default"`
- Check item name matches exactly: "AWS-Default" and "AWS-NX"
- Test BW access: `bw get username "AWS-Default"`

### "credential_process failed"
- Test script directly: `~/.local/bin/aws-bw-credentials "AWS-Default"`
- Check script permissions: `chmod +x ~/.local/bin/aws-bw-credentials`
- Verify BW session: `bw status`

## Security Benefits

✅ **Explicit credential mapping** - Clear which BW item each profile uses  
✅ **Only 2 BW items** to manage (AWS-Default, AWS-NX)  
✅ **No hardcoded credentials** anywhere in config files  
✅ **Separate credential sets** for different AWS accounts  
✅ **All existing profiles preserved** - just new credential sources  
✅ **Cross-platform** - works on Windows, Linux, macOS
