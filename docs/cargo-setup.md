# Cargo Integration Guide

This guide explains how to use and configure Cargo (Rust package manager) in your dotfiles setup.

## Overview

Cargo integration provides:
- **Cross-platform Rust toolchain** via rustup
- **Package management** for Rust crates
- **Automatic installation** during dotfiles setup
- **Configuration management** via Chezmoi templates

## Installation

### Automatic Installation

Cargo is installed automatically when you apply your dotfiles:

1. **rustup** is installed via your package managers:
   - **Linux**: Homebrew (`brew install rustup`)
   - **Windows**: Scoop (`scoop install rustup`)

2. **Rust toolchain** is initialized via installation scripts
3. **Cargo packages** are installed if enabled

### Manual Installation

If you need to install manually:

```bash
# Linux/macOS
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Windows (PowerShell)
Invoke-WebRequest -Uri https://win.rustup.rs -OutFile rustup-init.exe
.\rustup-init.exe
```

## Configuration

### Package Management

Cargo packages are configured in `home/.chezmoidata/pkgs/cargo.yml`:

```yaml
# Installation is controlled via Chezmoi data (.installCargoPackages)
# Package configuration
pkgs:
  cargo:
    testing:
      - 'pik'  # Image picker utility

    cli_essentials:
      - 'ripgrep'    # Fast grep alternative
      - 'fd-find'    # Fast find alternative
      - 'bat'        # Cat with syntax highlighting

    development:
      - 'cargo-edit'     # Cargo add/remove commands
      - 'cargo-watch'    # Watch for changes
      - 'cargo-expand'   # Show macro expansions

    system_tools:
      - 'dust'       # Disk usage analyzer
      - 'procs'      # Process viewer
      - 'delta'      # Git diff highlighter

    utilities:
      - 'starship'   # Cross-shell prompt
      - 'bottom'     # System monitor
```

### Enabling Package Installation

By default, Cargo package installation is **disabled** for safety.

#### Option 1: During Chezmoi Init (Recommended)
When you run `chezmoi init`, you'll be prompted:
```
Install Cargo packages (Rust crates)? This may take some time [y/N]:
```

#### Option 2: Change Setting Later
```bash
# Enable Cargo packages
chezmoi data set installCargoPackages true
chezmoi apply

# Disable Cargo packages
chezmoi data set installCargoPackages false
```

#### Option 3: Reconfigure
```bash
# Re-run the configuration prompts
chezmoi init --reconfigure
```

### Adding New Packages

1. Edit `home/.chezmoidata/pkgs/cargo.yml`
2. Add packages to appropriate categories
3. Run `chezmoi apply` (if `installCargoPackages` is enabled)

## Usage

### Basic Commands

```bash
# Install a package
cargo install package-name

# Update all installed packages
cargo install-update -a

# List installed packages
cargo install --list

# Uninstall a package
cargo uninstall package-name
```

### Package Categories

- **cli_essentials**: Core CLI tools and replacements
- **development**: Development and debugging tools
- **system_tools**: System monitoring and management
- **utilities**: General productivity tools
- **testing**: Packages for testing the setup

## Configuration Files

### Cargo Config (`~/.cargo/config.toml`)

The following configuration is automatically applied:

```toml
[build]
jobs = 0  # Use all CPU cores

[net]
git-fetch-with-cli = true  # Better authentication

[profile.release]
lto = true  # Link-time optimization
codegen-units = 1

[registries.crates-io]
protocol = "sparse"  # Faster registry protocol
```

### PATH Configuration

Cargo's bin directory (`~/.cargo/bin`) is automatically added to your PATH in:
- **Bash**: `home/.chezmoitemplates/shell/init-bash.tmpl`
- **Fish**: `home/.chezmoitemplates/shell/init-fish.tmpl`
- **PowerShell**: `home/.chezmoitemplates/powershell/profile.ps1.tmpl`

## Troubleshooting

### Cargo Not Found

If cargo commands aren't available:

1. **Check installation**:
   ```bash
   rustup show
   ```

2. **Source environment** (Linux/macOS):
   ```bash
   source ~/.cargo/env
   ```

3. **Restart terminal** (Windows)

### Package Installation Fails

1. **Update Rust**:
   ```bash
   rustup update
   ```

2. **Clear registry cache**:
   ```bash
   rm -rf ~/.cargo/registry/cache
   ```

3. **Check build dependencies** (Linux):
   ```bash
   sudo apt install build-essential
   ```

### Permission Issues

On Linux/macOS, ensure proper permissions:
```bash
chmod +x ~/.cargo/bin/*
```

## Integration with Other Tools

### Homebrew vs Cargo

Some tools are available in both Homebrew and Cargo:

- **Existing tools**: Keep in Homebrew to avoid conflicts
- **New tools**: Add to Cargo for Rust ecosystem benefits
- **Migration**: Move tools gradually if desired

### Topgrade Integration

Cargo packages are updated via topgrade when enabled in the topgrade configuration.

## Best Practices

1. **Start small**: Enable with just a few packages initially
2. **Test first**: Use the testing category for new packages
3. **Document changes**: Note any package additions in commits
4. **Regular updates**: Keep toolchain and packages updated
5. **Check dependencies**: Some packages may need system libraries

## Common Packages

### Recommended CLI Tools

- **ripgrep** (`rg`): Faster grep
- **fd-find** (`fd`): Faster find
- **bat**: Cat with syntax highlighting
- **exa**: Modern ls replacement
- **delta**: Git diff syntax highlighter

### Development Tools

- **cargo-edit**: Add/remove dependencies easily
- **cargo-watch**: Auto-run commands on file changes
- **cargo-expand**: Show macro expansions
- **cargo-audit**: Security vulnerability scanner

### System Tools

- **dust**: Disk usage analyzer
- **procs**: Process viewer
- **bottom**: System monitor
- **hyperfine**: Command benchmarking

## References

- [Cargo Documentation](https://doc.rust-lang.org/cargo/)
- [rustup Documentation](https://rust-lang.github.io/rustup/)
- [Rust Crates Registry](https://crates.io/)
- [Cargo Configuration](https://doc.rust-lang.org/cargo/reference/config.html)
