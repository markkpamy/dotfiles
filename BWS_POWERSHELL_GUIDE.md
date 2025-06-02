# BWS Helper Functions - Windows PowerShell Implementation

## 🪟 Windows PowerShell Integration

Your BWS helper functions are now available in PowerShell with the same clean `bws-run` interface you have in Bash and Fish!

## 🚀 PowerShell-Specific Features

### **Core Functions (PowerShell Native)**
- `Invoke-BWSRun` - The PowerShell equivalent of your `bws-run` function
- `Invoke-BWSInject` - Environment injection for PowerShell commands
- `Get-BitwardenPassword` - Secure password retrieval
- `Invoke-BitwardenUnlock` / `Invoke-BitwardenLock` - Session management

### **Same Aliases as Unix Systems**
```powershell
# Core BWS functionality (identical to Bash/Fish)
bws-run secret list                    # List secrets
bws-run project list                   # List projects  
bws-run secret get <secret-id>         # Get specific secret
bws-run secret create "KEY" "value"    # Create new secret

# Same quick aliases
bwu          # bw-unlock
bwl          # bw-lock
bwi          # bw-info  
bwp          # bw-get-password
bwh          # bw-help
```

## 💡 PowerShell Usage Examples

### **Daily Development Workflow**
```powershell
# Morning routine
bwu                                    # Unlock vault
bws-run project list                   # Check available projects
bws-run secret list                    # List secrets

# Run development with secrets
bws-inject npm start                   # Start dev server with secrets
bws-inject dotnet run                  # Run .NET app with secrets
bws-inject python manage.py runserver # Django with secrets
```

### **Secret Management**
```powershell
# Create secrets for your project
bws-run secret create "DATABASE_URL" "postgresql://..."
bws-run secret create "API_KEY" "your-api-key"
bws-run secret create "REDIS_URL" "redis://localhost:6379"

# Update existing secrets  
bws-run secret update <secret-id> "NEW_API_KEY" "updated-value"

# Clean up old secrets
bws-run secret delete <old-secret-id>
```

### **Docker Integration**
```powershell
# Your existing Docker aliases work the same
dcus         # docker compose up with BWS secrets
dcds         # docker compose down

# Or use the function directly
bws-compose-up    # Start services with secrets
bws-compose-down  # Stop services
```

### **Project Management**
```powershell
# Manage BWS projects
bws-run project create "Development Environment"
bws-run project create "Production Environment"
bws-run project list

# Work with specific project
$env:BWS_PROJECT_ID = "your-project-id"
bws-run secret list    # Lists secrets in that project
```

## 🔧 Windows-Specific Implementation Details

### **File Permissions**
- Session files use Windows ACLs (equivalent to `chmod 600` on Unix)
- Only the current user has access to session files
- Automatic cleanup on vault lock

### **Error Handling**
- PowerShell-native error handling with `try/catch`
- Proper exit code checking with `$LASTEXITCODE`
- Silent error redirection with `2>$null`

### **Environment Variables**
- Uses `$env:` PowerShell syntax for environment variables
- Automatic configuration from Chezmoi templates
- Seamless integration with existing PowerShell profile

### **Command Execution**
- Uses PowerShell's `&` call operator for external commands
- Proper argument splatting with `@Arguments`
- PowerShell parameter binding for flexible function calls

## 🎯 Cross-Platform Consistency

Your BWS implementation now works identically across:

| Feature | Bash | Fish | PowerShell |
|---------|------|------|------------|
| `bws-run secret list` | ✅ | ✅ | ✅ |
| `bws-run project list` | ✅ | ✅ | ✅ |
| `bws-inject <command>` | ✅ | ✅ | ✅ |
| Token from vault | ✅ | ✅ | ✅ |
| Session management | ✅ | ✅ | ✅ |
| Docker integration | ✅ | ✅ | ✅ |
| Same aliases | ✅ | ✅ | ✅ |

## 🛠️ Installation & Setup

### **1. Apply Dotfiles Changes**
```powershell
cd C:\Users\markk\Documents\GitRepos\dotfiles
chezmoi apply
```

### **2. Restart PowerShell**
```powershell
# Restart your PowerShell session to load new functions
```

### **3. Verify Installation**
```powershell
# Check if functions are loaded
Get-Command bws-run
Get-Command bw-unlock

# Test Bitwarden status  
bw-info

# Test BWS integration (after storing token in vault)
bws-run project list
```

## 🚨 Windows-Specific Troubleshooting

### **"bws-run not recognized"**
```powershell
# Restart PowerShell session
# Or reload profile manually
. $PROFILE
```

### **"Execution Policy" errors**
```powershell
# Check current policy
Get-ExecutionPolicy

# Set policy for current user (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### **"jq not found" errors**
```powershell
# Install jq via your package manager or Chezmoi externals
# Your dotfiles should handle this automatically
```

### **File permission issues**
```powershell
# Check session file permissions
Get-Acl $env:BW_UTILS_SESSION_FILE | Format-List

# Session files should only be accessible by current user
```

## 🎉 Ready to Use!

Your BWS helper functions are now available in PowerShell with the same excellent design:

- **Simple**: `bws-run` provides direct access to all BWS functionality
- **Secure**: Token encrypted in vault, never exposed  
- **Consistent**: Same commands work across Bash, Fish, and PowerShell
- **Windows-native**: Proper PowerShell implementation with Windows file permissions

Your clean `bws-run` architecture scales perfectly to Windows! 🚀
