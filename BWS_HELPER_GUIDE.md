# BWS Helper Functions - Comprehensive Guide

## 🚀 Overview

Your dotfiles include a powerful, secure BWS (Bitwarden Secrets Manager) integration built around the core `bws-run` function. This implementation follows the Unix philosophy of simple, composable tools while providing enterprise-grade security for secret management.

## 🏗️ Architecture

### Core Components

1. **Token Management**: Secure retrieval from Bitwarden vault
2. **BWS Execution**: Direct CLI interface with automatic authentication
3. **Environment Injection**: Seamless secret injection into commands
4. **Docker Integration**: Secure container deployments
5. **Session Management**: Automatic Bitwarden vault handling

### Configuration Variables

```yaml
# Located in: home/.chezmoidata/global.yml
bitwarden:
  enabled: true
  token_item: "BWS Access Token"           # Vault item containing BWS token
  storage_method: "login"                  # How token is stored (login/field)
  default_project: "your-project-id"      # Default BWS project ID (optional)
```

## 🔧 Core Functions

### `bws-run` - The Heart of BWS Integration

**Purpose**: Execute any BWS command with automatic token authentication

**Syntax**: `bws-run <bws-command> [arguments...]`

**How it works**:
1. Verifies BWS CLI is installed
2. Retrieves access token from Bitwarden vault
3. Executes BWS command with token authentication
4. Returns BWS output directly

**Examples**:
```bash
# List all secrets
bws-run secret list

# Get specific secret
bws-run secret get <secret-id>

# Create new secret
bws-run secret create "API_KEY" "your-secret-value"

# List projects
bws-run project list

# Get project details
bws-run project get <project-id>

# List secrets in specific project
bws-run secret list --project-id <project-id>

# Update secret
bws-run secret update <secret-id> "NEW_API_KEY" "new-value"

# Delete secret
bws-run secret delete <secret-id>

# Create project
bws-run project create "My Project"

# Any other BWS command
bws-run <command> [args...]
```

### `bws-inject` - Environment Variable Injection

**Purpose**: Run any command with BWS secrets automatically injected as environment variables

**Syntax**: `bws-inject <command> [arguments...]`

**How it works**:
1. Retrieves BWS token from vault
2. Uses BWS run command to inject secrets
3. Automatically uses default project if configured
4. Executes your command in enriched environment

**Examples**:
```bash
# Run application with secrets
bws-inject npm start

# Execute script with database credentials
bws-inject ./deploy-script.sh

# Run Docker container with secrets
bws-inject docker run -it myapp:latest

# Start development server with API keys
bws-inject python manage.py runserver

# Execute any command with secrets available
bws-inject your-command --with-args
```

### `bws-compose-up` / `bws-compose-down` - Docker Compose Integration

**Purpose**: Secure Docker Compose workflows with automatic secret injection

**Syntax**:
- `bws-compose-up` - Start services with secrets
- `bws-compose-down` - Stop services

**Examples**:
```bash
# Start all services with BWS secrets
bws-compose-up

# Stop all services
bws-compose-down

# Available aliases (if docker_secure enabled)
dcus    # docker compose up with BWS secrets
dcds    # docker compose down
dcubs   # docker compose up --build with BWS secrets
dcss    # docker compose stop with BWS secrets
dcrs    # docker compose restart with BWS secrets
dcls    # docker compose logs with BWS secrets
```

## 🔐 Token Management System

### `bws-get-token` - Secure Token Retrieval

**How it works**:
1. Automatically unlocks Bitwarden vault if needed
2. Retrieves token from configured vault item
3. Supports two storage methods:
   - `login`: Token stored as password in login item
   - `field`: Token stored in custom field named "token"

**Configuration examples**:
```yaml
# Store token as password in login item (default)
bitwarden:
  token_item: "BWS Access Token"
  storage_method: "login"

# Store token in custom field
bitwarden:
  token_item: "My BWS Service Account"
  storage_method: "field"
```

## 🛠️ Supporting Functions

### Bitwarden Vault Management

```bash
# Unlock vault
bw-unlock          # Alias: bwu

# Lock vault and clear session
bw-lock            # Alias: bwl

# Show vault and BWS status
bw-info            # Alias: bwi

# Get help
bw-help            # Alias: bwh
```

### Secret Retrieval Functions

```bash
# Get password from vault item
bw-get-password "Item Name"           # Alias: bwp

# Get username from vault item
bw-get-username "Item Name"

# Get custom field from vault item
bw-get-field "Item Name" "field-name"
```

### Environment Variable Management

```bash
# Export secrets as environment variables
bw-export-env "Database Password:DB_PASS" "API Key:API_TOKEN"

# Clear exported environment variables
bw-clear-env DB_PASS API_TOKEN

# Generate .env file from vault
bw-generate-env .env "Database:DB_URL" "Redis:REDIS_URL"
```

## 📚 Common Use Cases

### 1. Development Workflow

```bash
# Daily workflow
bw-unlock                              # Unlock vault once
bws-run project list                   # See available projects
bws-run secret list                    # List secrets in current project
bws-inject npm run dev                 # Start development with secrets
```

### 2. Deployment Pipeline

```bash
# CI/CD integration
bw-unlock                              # Authenticate
bws-compose-up                         # Deploy with secrets
# or
bws-inject ./deploy.sh production      # Custom deployment script
```

### 3. Secret Management

```bash
# Create new API key
bws-run secret create "STRIPE_API_KEY" "sk_live_..."

# Update existing secret
bws-run secret update <secret-id> "STRIPE_API_KEY" "sk_live_new..."

# List all secrets with project filter
bws-run secret list --project-id <project-id>

# Delete old secret
bws-run secret delete <old-secret-id>
```

### 4. Project Management

```bash
# Create new project for environment
bws-run project create "Production Environment"

# Set as default project (session only)
export BWS_PROJECT_ID="<project-id>"

# List project secrets
bws-run secret list --project-id $BWS_PROJECT_ID
```

### 5. Environment File Generation

```bash
# Generate .env for local development
bw-generate-env .env.local \
  "Database URL:DATABASE_URL" \
  "Redis URL:REDIS_URL" \
  "API Key:API_KEY"

# Export for current session
bw-export-env \
  "Database Password:DB_PASS" \
  "API Token:API_TOKEN"
```

## 🔒 Security Features

### 1. **Secure Token Storage**
- BWS access token encrypted in Bitwarden vault
- No plain-text tokens in environment or files
- Automatic token retrieval with vault authentication

### 2. **Session Management**
- Automatic vault unlocking when needed
- Secure session file with restricted permissions (600)
- Clean session cleanup on vault lock

### 3. **Error Handling**
- Graceful failure with helpful error messages
- Token validation before BWS operations
- CLI availability checking

### 4. **Audit Trail**
- All BWS operations logged by Bitwarden
- Clear command output with visual indicators
- No token exposure in command history

## 🎯 Best Practices

### 1. **Token Management**
```bash
# Store BWS token in dedicated vault item
# Item name: "BWS Access Token"
# Password field: your-actual-bws-token
# Never store tokens in scripts or environment
```

### 2. **Project Organization**
```yaml
# Set default project in global.yml for convenience
bitwarden:
  default_project: "your-main-project-id"
```

### 3. **Development Workflow**
```bash
# Daily routine
bw-unlock                    # Once per session
bw-info                      # Verify status
bws-inject your-dev-command  # Use for development

# End of day
bw-lock                      # Secure cleanup
```

### 4. **CI/CD Integration**
```bash
# In CI/CD scripts
bw-unlock || exit 1              # Fail fast if auth fails
bws-inject ./deployment-script   # Deploy with secrets
bw-lock                          # Clean up
```

## 🚨 Troubleshooting

### Common Issues

**1. "BWS CLI not found"**
```bash
# Install BWS CLI (already in your externals config)
chezmoi apply  # This installs BWS via externals
```

**2. "Failed to get BWS token"**
```bash
# Check vault item exists
bw-unlock
bw get item "BWS Access Token"

# Verify token storage method in global.yml
```

**3. "Please login and unlock Bitwarden first"**
```bash
# Login to Bitwarden
bw login your-email@example.com

# Then unlock
bw-unlock
```

**4. "BWS API access failed"**
```bash
# Test token validity
bws-run --help

# Check project permissions
bws-run project list
```

### Diagnostic Commands

```bash
# Check overall status
bw-info

# Test BWS connection
bws-run project list

# Verify token retrieval
bws-get-token > /dev/null && echo "Token OK" || echo "Token Failed"

# Check configuration
echo "Token Item: $BWS_TOKEN_ITEM"
echo "Storage Method: $BWS_STORAGE_METHOD"
echo "Default Project: $BWS_PROJECT_ID"
```

## 🔄 Migration and Updates

### Updating BWS Token
```bash
# 1. Generate new token in Bitwarden web app
# 2. Update vault item
bw-unlock
bw edit item "BWS Access Token"  # Update password field

# 3. Test new token
bws-run project list
```

### Changing Default Project
```yaml
# Update global.yml
bitwarden:
  default_project: "new-project-id"

# Apply changes
chezmoi apply

# Or set temporarily
export BWS_PROJECT_ID="new-project-id"
```

## 🎉 Advanced Usage

### Custom BWS Operations
```bash
# Batch secret creation
for key in API_KEY DB_PASS REDIS_URL; do
  value=$(generate-secret)  # Your secret generation
  bws-run secret create "$key" "$value"
done

# Secret rotation
old_secret_id=$(bws-run secret list | jq -r '.[] | select(.key=="API_KEY") | .id')
bws-run secret delete "$old_secret_id"
bws-run secret create "API_KEY" "$(generate-new-api-key)"
```

### Integration with Other Tools
```bash
# With Terraform
bws-inject terraform apply

# With Ansible
bws-inject ansible-playbook -i inventory playbook.yml

# With kubectl
bws-inject kubectl apply -f k8s-manifests/

# With custom scripts
bws-inject ./backup-database.sh
bws-inject ./sync-secrets.py
```

## 📖 Reference

### Available Aliases
```bash
# Core functions
bwu     # bw-unlock
bwl     # bw-lock  
bwi     # bw-info
bwp     # bw-get-password
bwh     # bw-help

# Docker with secrets (if enabled)
dcus    # bws-compose-up
dcds    # bws-compose-down
dcubs   # docker compose up --build with BWS
dcss    # docker compose stop with BWS
dcrs    # docker compose restart with BWS
dcls    # docker compose logs with BWS
```

### Configuration Files
```
home/
├── .chezmoidata/
│   └── global.yml                           # BWS configuration
├── .chezmoitemplates/
│   └── bitwarden/
│       ├── functions-bash.tmpl              # BWS functions
│       ├── functions-fish.tmpl              # Fish shell version
│       └── aliases.tmpl                     # BWS aliases
└── .config/
    └── bitwarden-utils/
        ├── config                           # Runtime config
        └── session                          # Secure session file
```

### Environment Variables
```bash
BWS_TOKEN_ITEM        # Vault item containing BWS token
BWS_STORAGE_METHOD    # Token storage method (login/field)  
BWS_PROJECT_ID        # Default BWS project ID
BW_UTILS_CONFIG_DIR   # Configuration directory
BW_SESSION           # Bitwarden session (auto-managed)
```

---

## 🎯 Why This Design is Excellent

1. **Simplicity**: `bws-run` provides direct access to all BWS functionality
2. **Security**: Token encrypted in vault, never exposed in plain text
3. **Flexibility**: Works with any BWS command or future additions
4. **Composability**: Follows Unix philosophy - do one thing well
5. **Integration**: Seamless with existing dotfiles and workflows
6. **Maintainability**: Minimal code surface area, easy to understand
7. **Reliability**: Robust error handling and status checking

Your BWS helper implementation is a perfect example of thoughtful system design! 🚀
