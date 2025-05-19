# Pre-commit Framework Setup

This configuration uses [pre-commit](https://pre-commit.com/) framework to manage Git hooks for code quality, security, and consistency across your repositories.

## What's Included

### 🔧 **Core Configuration** (`.pre-commit-config.yaml`)

The pre-commit configuration includes:

1. **Standard Hooks** - Basic file and formatting checks
   - Trailing whitespace removal
   - End-of-file fixing
   - YAML/JSON/TOML validation
   - Large file detection
   - Merge conflict detection

2. **Security Scanning**
   - **Gitleaks** - Secret detection in code
   - **detect-secrets** - Alternative secret scanning with baseline support

3. **Code Quality**
   - **Prettier** - Code formatter for YAML and other files
   - **Markdownlint** - Markdown linting and formatting
   - **Shellcheck** - Shell script analysis
   - **PowerShell Script Analyzer** - PowerShell script linting (Windows)

4. **Git Hygiene**
   - **Commitizen** - Conventional commit message validation

### 📋 **Configuration Files**

- `.pre-commit-config.yaml` - Main pre-commit configuration
- `.gitleaks.toml` - Custom gitleaks rules and settings
- `.gitleaksignore` - Global ignore patterns for gitleaks
- `.secrets.baseline` - Baseline for detect-secrets
- `.markdownlint.yaml` - Markdown linting rules
- `.prettierrc.yaml` - Prettier formatting configuration
- `.prettierignore` - Files to exclude from Prettier

## Installation

### Automatic Installation (via dotfiles)

Pre-commit is automatically installed and configured when you run `chezmoi apply`:

1. **Package Installation**:
   - Linux: `pre-commit` package or pip installation
   - Windows: pip installation + PSScriptAnalyzer PowerShell module
   - macOS: Homebrew installation

2. **Auto-setup**: Scripts automatically configure pre-commit in your dotfiles repository

### Manual Installation

If you need to install pre-commit manually:

**Linux/macOS:**
```bash
# Via package manager (recommended)
# Ubuntu/Debian:
sudo apt install pre-commit

# macOS:
brew install pre-commit

# Via pip (alternative):
pip3 install --user pre-commit
```

**Windows:**
```powershell
# Via pip (after installing Python):
python -m pip install --user pre-commit

# Via scoop:
scoop install pre-commit

# Via chocolatey:
choco install pre-commit
```

## Usage

### Setting Up in a Repository

To enable pre-commit in a Git repository:

```bash
# Navigate to your repository
cd /path/to/your/repo

# Install the hooks
pre-commit install --install-hooks

# Install additional hook types
pre-commit install --hook-type commit-msg
pre-commit install --hook-type pre-push
```

Or use the provided utility scripts:
- Linux/macOS: `./utils-linux/setup-pre-commit-repo.sh`
- Windows: `.\utils-windows\setup-pre-commit-repo.ps1`

### Manual Execution

```bash
# Run all hooks on all files
pre-commit run --all-files

# Run specific hook
pre-commit run gitleaks

# Run on specific files
pre-commit run --files file1.py file2.js

# Update hook versions
pre-commit autoupdate
```

### Bypassing Hooks (Not Recommended)

```bash
# Skip pre-commit hooks (emergency use only)
git commit --no-verify

# Skip specific hook
SKIP=gitleaks git commit -m "message"
```

## Hook Behavior

### Pre-commit Hooks (Run before each commit)

1. **File checks** - Validate file formats and detect issues
2. **Code formatting** - Auto-format code with Prettier
3. **Linting** - Check shell scripts, markdown, etc.
4. **Security scanning** - Scan for secrets with gitleaks and detect-secrets

### Commit-msg Hooks (Validate commit messages)

1. **Commitizen** - Enforce conventional commit format
   - Examples: `feat: add new feature`, `fix: resolve bug`

### Pre-push Hooks (Run before pushing)

Optional additional checks before code reaches remote repositories.

## Customization

### Adding Custom Hooks

Edit `.pre-commit-config.yaml` to add new repositories and hooks:

```yaml
repos:
  - repo: https://github.com/your-org/your-hooks
    rev: v1.0.0
    hooks:
      - id: your-custom-hook
        args: [--your-arg]
```

### Configuring Existing Hooks

Many hooks can be configured via their respective config files:

- **Gitleaks**: Edit `.gitleaks.toml`
- **Markdownlint**: Edit `.markdownlint.yaml`
- **Prettier**: Edit `.prettierrc.yaml`
- **detect-secrets**: Edit `.secrets.baseline`

### Per-Repository Overrides

Create a local `.pre-commit-config.yaml` in specific repositories to:
- Skip certain hooks
- Add project-specific hooks
- Override global configuration

Example:
```yaml
# Local override
repos:
  - repo: local
    hooks:
      - id: project-specific-check
        name: Project Specific Check
        entry: ./scripts/check.sh
        language: script
```

## Troubleshooting

### Common Issues

1. **Hook installation fails**
   - Ensure pre-commit is installed and in PATH
   - Check Python installation (required for many hooks)

2. **Gitleaks false positives**
   - Add patterns to `.gitleaksignore`
   - Update `.gitleaks.toml` configuration

3. **Performance issues**
   - Use `exclude` patterns in configuration
   - Run hooks on specific file types only

4. **Commit blocked by hooks**
   - Fix the issues reported by the hooks
   - Use `git commit --no-verify` only in emergencies

### Getting Help

```bash
# Check pre-commit version
pre-commit --version

# Validate configuration
pre-commit validate-config

# Clean and reinstall hooks
pre-commit clean
pre-commit install --install-hooks
```

## Best Practices

1. **Regular Updates**
   - Run `pre-commit autoupdate` monthly
   - Test updates before committing

2. **Team Adoption**
   - Document pre-commit setup in project README
   - Include installation in onboarding process

3. **CI/CD Integration**
   - Run `pre-commit run --all-files` in CI pipelines
   - Ensure consistency between local and remote checks

4. **Gradual Introduction**
   - Start with basic hooks
   - Add more strict rules gradually
   - Use `exclude` patterns for legacy code

## Security Considerations

- **Never commit secrets** even if temporarily ignoring detection
- **Review .gitleaksignore** regularly for validity
- **Use proper secret management** tools (env vars, vaults, etc.)
- **Educate team members** on security practices

## Links

- [Pre-commit Documentation](https://pre-commit.com/)
- [Pre-commit Hooks Repository](https://github.com/pre-commit/pre-commit-hooks)
- [Gitleaks](https://github.com/gitleaks/gitleaks)
- [detect-secrets](https://github.com/Yelp/detect-secrets)
- [Prettier](https://prettier.io/)
- [Markdownlint](https://github.com/DavidAnson/markdownlint)
