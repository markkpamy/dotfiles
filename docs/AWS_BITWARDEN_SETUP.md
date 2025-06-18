# AWS + Bitwarden Simple Security Setup Guide

Clean and simple AWS authentication with **complete credential and metadata security** using Chezmoi templates directly.

## Security Features

✅ **AWS credentials** stored in Bitwarden Secrets Manager  
✅ **Account numbers** hidden in BWS (not in config files)  
✅ **Role ARNs** dynamically generated from BWS metadata  
✅ **Profile information** centrally managed in BWS  
✅ **Direct template integration** - no separate generators needed
✅ **Fallback support** - works even if BWS unavailable  

## Setup Steps

### 1. Store AWS Information in Bitwarden Secrets Manager

```bash
# Base AWS credentials
bws secret create "aws-default-access-key-id" "XXXXXXXXXXXXX" "$BWS_PROJECT_ID"
bws secret create "aws-default-secret-access-key" "XXXXXXXXXXXXX" "$BWS_PROJECT_ID"

# Profile metadata (see BWS_AWS_SECRETS_SETUP.md for complete JSON)
bws secret create "aws-profiles-metadata" '{ ... }'
```

### 2. Deploy Configuration

```bash
cd ~/dotfiles

# Set BWS session for template processing
bwst

# Deploy with secrets integration
chezmoi apply
```

### 3. Test Integration

```bash
# Test complete setup
aws-test

# View profile information (without exposing account numbers)
aws-profiles

# Test profile switching
aws-dev
aws sts get-caller-identity
```

## How It Works

### Template Integration
```yaml
# Chezmoi template directly fetches from BWS:
{{- $bwsResult := output "bws" "secret" "get" "aws-profiles-metadata" ... -}}
{{- $profilesJson = $bwsResult | fromJson -}}

# Then generates config dynamically:
{{- range $profileName, $profileData := $profilesJson }}
[profile {{ $profileName }}]
role_arn = arn:aws:iam::{{ $profileData.account_id }}:role/{{ $profileData.role_name }}
{{- end }}
```

### Fallback Safety
- If BWS unavailable → Uses static fallback config
- If BWS_ACCESS_TOKEN missing → Uses static fallback config  
- If bws command not found → Uses static fallback config

## Available Commands

### Profile Management
- `aws-profile [name]` - Switch profiles or show current
- `aws-test` - Test AWS configuration
- `aws-dev`, `aws-prod`, etc. - Quick profile switching

### Configuration Management  
- `aws-config-update` - Refresh config from Bitwarden (re-applies Chezmoi)
- `aws-profiles` - Show profile information without exposing account numbers

## Updating Profiles

### Add New Profile
```bash
# 1. Edit BWS metadata
bws secret edit "aws-profiles-metadata"  # Add new profile to JSON

# 2. Refresh config
bwst && aws-config-update
```

### Update Account Numbers
```bash  
# 1. Edit BWS metadata
bws secret edit "aws-profiles-metadata"  # Update account_id

# 2. Refresh config  
bwst && aws-config-update
```

### Rotate Credentials
```bash
# 1. Update in BWS
bws secret edit "aws-default-access-key-id"
bws secret edit "aws-default-secret-access-key"

# 2. Test immediately (no config update needed)
aws-test
```

## Security Architecture

### Clean Template Approach
- ✅ **Direct BWS integration** in Chezmoi templates
- ✅ **No generator scripts** to maintain
- ✅ **Simple workflow** - just `chezmoi apply`
- ✅ **Automatic fallback** to static config if BWS unavailable
- ✅ **Zero complexity** - leverages existing Chezmoi functionality

### Before vs After
```ini
# BEFORE: Exposed account numbers
role_arn = arn:aws:iam::766272829042:role/nx-training-advanced

# AFTER: Dynamic from encrypted BWS
{{- range $profileName, $profileData := $profilesJson }}
role_arn = arn:aws:iam::{{ $profileData.account_id }}:role/{{ $profileData.role_name }}
{{- end }}
```

## Troubleshooting

### "Config not updating with BWS data"
- Check BWS session: `bwst`
- Verify template processing: `chezmoi apply --dry-run ~/.aws/config`
- Check BWS secret: `bws secret get aws-profiles-metadata`

### "Fallback config being used"
- This is normal if BWS_ACCESS_TOKEN not set
- Set token: `bwst`
- Re-apply: `chezmoi apply ~/.aws/config`

### "Profile not working"
- Check JSON format: `bws secret get aws-profiles-metadata | jq`
- Validate account ID: Must be 12-digit string
- Check role name: Case-sensitive

## Benefits

🎯 **Simplicity** - No generator scripts, just Chezmoi templates  
🔒 **Security** - Account numbers and credentials hidden in BWS  
🔄 **Flexibility** - Easy to update profiles and credentials  
⚡ **Performance** - Direct template processing, no external scripts  
🛡️ **Reliability** - Automatic fallback if BWS unavailable  
📦 **Maintainable** - Leverages existing Chezmoi infrastructure
