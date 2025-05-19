# Gitleaks Pre-commit Hook Setup

This configuration adds gitleaks as a pre-commit hook to prevent secrets from being committed to your Git repositories.

## What's Included

1. **Pre-commit Hook** (`~/.config/git/hooks/pre-commit`)
   - Automatically runs gitleaks on staged files before each commit
   - Prevents commits if secrets are detected
   - Provides helpful instructions on how to resolve issues

2. **Gitleaks Configuration** (`~/.config/git/gitleaks.toml`)
   - Custom configuration with additional rules for common secrets
   - Whitelist for certain file types and patterns
   - Specific rules for Bitwarden tokens and Kubernetes configs

3. **Ignore File** (`~/.gitleaksignore`)
   - File to suppress false positives
   - Global ignore patterns for non-sensitive values

4. **Git Configuration Update**
   - Updated `~/.config/git/config` to use custom hooks directory
   - Ensures the pre-commit hook is used across all repositories

## Installation

Gitleaks will be automatically installed through your package managers:

- **Windows**: Installed via winget (`Gitleaks.Gitleaks`)
- **Linux**: Installed via the official installation script
- **macOS**: Installed via Homebrew (`gitleaks`)

You can also manually install using the provided scripts:
- Linux/macOS: `./utils-linux/install-gitleaks.sh`
- Windows: `./utils-windows/install-gitleaks.ps1`

## Usage

The hook runs automatically on every commit. If secrets are detected:

1. The commit will be blocked
2. You'll see output showing what was detected
3. You have several options:
   - Remove the secrets from your code (recommended)
   - Add false positives to `.gitleaksignore`
   - Bypass with `git commit --no-verify` (not recommended)

## Customization

### Adding Custom Rules

Edit `~/.config/git/gitleaks.toml` to add custom detection rules:

```toml
[[rules]]
id = "my-custom-rule"
description = "Description of what this detects"
regex = '''your-regex-pattern'''
keywords = ["keyword1", "keyword2"]
```

### Ignoring False Positives

Add entries to `~/.gitleaksignore`:

```
# Ignore specific secret by hash
4fb0f85fa2e2c961a6e8e2b6e7b2d4c3e5f6a7b8

# Ignore specific line in file
some-file.txt:generic-api-key:42

# Ignore rule in all markdown files
*.md:generic-password
```

### Manual Scanning

You can manually run gitleaks on your repository:

```bash
# Scan all files
gitleaks detect

# Scan specific files
gitleaks protect --staged

# Scan with custom config
gitleaks detect --config ~/.config/git/gitleaks.toml
```

## Troubleshooting

### Hook Not Running

If the pre-commit hook isn't running, check:

1. Hook file is executable: `chmod +x ~/.config/git/hooks/pre-commit`
2. Git is using the correct hooks directory: `git config core.hooksPath`
3. You're in a Git repository when committing

### False Positives

If gitleaks detects something that isn't actually a secret:

1. Add it to `.gitleaksignore` (preferred)
2. Update the gitleaks configuration to exclude it
3. As a last resort, use `--no-verify` to bypass

### Performance Issues

For large repositories, you can:

1. Use `.gitleaksignore` to skip large files
2. Configure gitleaks to only scan certain file types
3. Run gitleaks only on changed files (default behavior)

## Security Notes

- Never commit actual secrets, even if temporarily ignoring them
- Regularly review and update your `.gitleaksignore` file
- Use proper secret management tools like Bitwarden, HashiCorp Vault, etc.
- Consider using environment variables or external secret management for sensitive data

## Links

- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [Gitleaks Configuration Reference](https://github.com/gitleaks/gitleaks/blob/master/config/gitleaks.toml)
- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
