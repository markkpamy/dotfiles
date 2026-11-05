```
╔════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                                ║
║                                                                                                ║
║   ███╗   ███╗██╗  ██╗         ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗    ║
║   ████╗ ████║██║ ██╔╝         ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝    ║
║   ██╔████╔██║█████╔╝█████╗    ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗    ║
║   ██║╚██╔╝██║██╔═██╗╚════╝    ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║    ║
║   ██║ ╚═╝ ██║██║  ██╗         ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║    ║
║   ╚═╝     ╚═╝╚═╝  ╚═╝         ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝    ║
║                                                                                                ║
║                          🚀 Cross-Platform Dotfiles with Chezmoi 🚀                           ║
║                                                                                                ║
║                                                                                                ║
║                                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════════════════════╝
```

Shamelessly inspired by [KevinNitroG/dotfiles](https://github.com/KevinNitroG/dotfiles)

A comprehensive cross-platform dotfiles repository managed with [chezmoi](https://www.chezmoi.io/).

## Overview

This repository contains personal dotfiles for:
- **Linux** (Ubuntu/Debian, Arch/Manjaro, Fedora)
- **Windows** (10/11)

## Features

### 🛠️ **Core Configuration**
- **Cross-platform shell support**: Bash, Fish, Zsh, PowerShell, Nushell
- **Terminal emulators**: Windows Terminal, Tabby, with consistent theming
- **Development environment**: Git, Docker, Kubernetes, Terraform, Neovim
- **Window management**: komorebi/glazewm (Windows), i3/sway (Linux)

### 📦 **Package Management**
- **Windows**: Scoop, Chocolatey, WinGet, PowerShell Gallery
- **Linux**: Homebrew, APT, Pacman, Flatpak, Snap
- **Cross-platform**: pip, pipx for Python packages
- **Modern Python**: UV (fast pip replacement) and UVX (fast pipx replacement)

### 🔒 **Security & Quality**
- **Secret management**: Bitwarden integration
- **Encryption**: GPG and Age support for sensitive files
- **Pre-commit hooks**: [Gitleaks](docs/gitleaks-setup.md), linting, formatting
- **SSH key management**: Automated setup and Git signing

### 🎨 **UI & Productivity**
- **Unified theming**: Oh My Posh, Starship prompts
- **CLI utilities**: bat, eza, fd, fzf, ripgrep, delta, lazygit
- **Desktop environment**: Automatic detection and configuration

## Requirements

- [chezmoi](https://www.chezmoi.io/) - dotfiles manager
- **Windows**: PowerShell 5.1+ or PowerShell Core 7+
- **Linux**: Bash, or your preferred shell (auto-detected)
- **Optional**: Bitwarden CLI for secret management

## Quick Setup

### 🐧 **Linux (One Command)**

```bash
# Initialize and apply dotfiles in one step
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply markkpamy
```

### 🪟 **Windows (One Command)**

```powershell
# Initialize and apply dotfiles in one step
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -- init --apply --depth 1 --purge-binary markkpamy"
```

## Detailed Setup Instructions

### Linux Setup

1. **Install chezmoi**:
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
   ```

2. **Initialize with this repository**:
   ```bash
   chezmoi init https://github.com/markkpamy/dotfiles.git
   ```

3. **Preview changes** (optional):
   ```bash
   chezmoi diff
   ```

4. **Apply configuration**:
   ```bash
   chezmoi apply
   ```

**Alternative - One step initialization:**
```bash
chezmoi init --apply https://github.com/markkpamy/dotfiles.git
```

### Windows Setup

1. **Install chezmoi** using one of these methods:

   **Option A: PowerShell (Recommended)**
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   irm -useb get.chezmoi.io/ps1 | iex
   ```

   **Option B: Package Managers**
   ```powershell
   # Using Winget
   winget install twpayne.chezmoi

   # Using Chocolatey
   choco install chezmoi

   # Using Scoop
   scoop install chezmoi
   ```

2. **Initialize and apply** in one step:
   ```powershell
   chezmoi init --apply https://github.com/markkpamy/dotfiles.git
   ```

   **Note**: You'll be prompted to install packages (Scoop, Chocolatey, WinGet, Python packages). This process can take 15-30 minutes on first run.

3. **Quick setup without packages** (faster):
   ```powershell
   chezmoi init --apply https://github.com/markkpamy/dotfiles.git -- --installScoopPackages=false --installChocoPackages=false --installPythonPackages=false
   ```

**Preview changes before applying:**
```powershell
chezmoi init https://github.com/markkpamy/dotfiles.git
chezmoi diff
```

## Configuration During Setup

During the initial setup, you'll be prompted for:

### 🐧 **Linux**
- **Shell preference**: bash/zsh/fish (auto-detected)
- **Desktop environment**: Automatically detected (GNOME, KDE, XFCE, etc.)
- **Package installation**: Python packages via pip/pipx and modern UV/UVX

### 🪟 **Windows**  
- **Scoop packages**: Development tools, CLI utilities
- **Chocolatey packages**: Additional Windows applications
- **WinGet packages**: Microsoft Store and system tools
- **Python packages**: Development tools and CLI applications via pip/pipx and UV/UVX

### 🔐 **Both Platforms**
- **Bitwarden access token**: For secret management (optional but recommended). Asked for once with a hidden prompt and kept in the OS keystore (Windows Credential Manager, Secret Service, macOS Keychain), never in `chezmoi.toml`
- **GPG/SSH setup**: For Git signing and authentication

## Directory Structure

```
dotfiles/
├── .pre-commit-config.yaml          # Code quality and security hooks
├── .gitleaks.toml                   # Secret detection configuration
├── docs/                            # Documentation
│   ├── CHEZMOI.md                   # Chezmoi usage guide
│   ├── pre-commit-setup.md          # Pre-commit framework setup
│   ├── windows.md                   # Windows-specific notes
│   └── linux.md                     # Linux-specific notes
└── home/                            # Chezmoi source directory
    ├── .chezmoi.toml.tmpl           # Main chezmoi configuration
    ├── .chezmoiignore.tmpl          # Platform-specific exclusions  
    ├── .chezmoiscripts/             # Automated setup scripts
    │   ├── linux/                   # Linux package installation
    │   ├── windows/                 # Windows package installation
    │   └── unix/                    # Shared Unix scripts
    ├── .chezmoidata/                # Configuration data
    │   └── pkgs/                    # Package definitions
    │       ├── windows.yml          # Windows packages
    │       ├── ubuntu.yml           # Ubuntu packages
    │       ├── arch-based.yml       # Arch packages
    │       ├── homebrew.yml         # Homebrew packages
    │       └── python.yml           # Python packages (pip, pipx, uv, uvx)
    ├── .chezmoiexternals/           # External dependencies
    ├── AppData/                     # Windows-specific configs
    │   └── Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/
    ├── Documents/PowerShell/       # PowerShell profiles
    ├── dot_config/                  # Unix configuration files
    │   ├── git/                     # Git configuration
    │   ├── nvim/                    # Neovim configuration
    │   ├── fish/                    # Fish shell
    │   ├── komorebi/                # Windows tiling manager
    │   └── ...                      # Other CLI tools
    ├── dot_local/bin/               # Custom scripts and binaries
    ├── utils-linux/                # Linux utility scripts  
    └── utils-windows/               # Windows utility scripts
```

### Key Features by Directory

**Cross-Platform Configuration:**
- `dot_oh-my-posh.json` - Unified prompt theme for all shells
- `dot_config/git/config.tmpl` - Git config with OS-specific sections
- `.chezmoiignore.tmpl` - Smart OS and desktop environment filtering

**Linux-Specific:**
- `dot_bashrc.tmpl` - Enhanced Bash configuration
- `dot_config/fish/` - Fish shell with custom functions
- `dot_config/starship/` - Alternative prompt configuration
- `run_once_linux/` - Distribution-specific package installation

**Windows-Specific:**
- `Documents/PowerShell/` - PowerShell profiles and modules
- `AppData/Local/` - Windows Terminal and app configurations
- `dot_config/komorebi/` - Tiling window manager
- `run_once_windows/` - Package manager automation

## Package Management

## Package Management

This dotfiles setup includes comprehensive package management across platforms:

### Modern Python Package Management (NEW)

**UV - Fast Pip Replacement:**
- ⚡ **10-100x faster** than pip for package resolution and installation
- 🔄 **Project-based dependencies** with automatic virtual environment management
- 📁 **pyproject.toml integration** for modern Python project structure
- 🔒 **Lock file generation** for reproducible environments

**UVX - Fast Pipx Replacement:**
- ⚡ **Instant tool execution** with minimal overhead
- 🛠️ **Persistent tool installation** using `uv tool install`
- 🔒 **Isolated environments** for each CLI application
- 🔄 **Easy upgrades** with `uv tool upgrade`

**Example UV/UVX configuration:**
```yaml
# python.yml
pkgs:
  python:
    linux:
      uv:                    # Project dependencies
        - 'requests'
        - 'click[dev]>=8.0'   # With extras and version constraints
        - 'pydantic>=2.0'
      uvx:                   # CLI applications
        - 'black'            # Code formatter
        - 'ruff'             # Fast linter
        - 'pre-commit'       # Git hooks
```

### Traditional Python Package Management

**Standard pip/pipx support** (for compatibility):
- pip for global packages and legacy workflows
- pipx for isolated CLI applications
- Both coexist with UV/UVX seamlessly

This dotfiles setup includes comprehensive package management across platforms:

### Windows Packages

**Automatically installed via:**
- **WinGet**: Core development tools (Git, Python, Neovim, Docker, Kubernetes tools)
- **Scoop**: CLI utilities and portable apps (optional, user-prompted)
- **Chocolatey**: Additional Windows applications (optional, user-prompted)
- **PowerShell Gallery**: PowerShell modules (PSReadLine, Terminal-Icons, posh-git)

**Key packages include:**
- Development: Git, Python, Node.js, Neovim, Docker Desktop
- CLI tools: bat, eza, fd, fzf, ripgrep, delta, lazygit, k9s
- Productivity: Windows Terminal, PowerToys, ObsidianMD

### Linux Packages

**Distribution-specific installation:**
- **Ubuntu/Debian**: APT packages + Snap/Flatpak for desktop apps
- **Arch/Manjaro**: Pacman packages + AUR helpers
- **Fedora**: DNF packages + Flatpak
- **Universal**: Homebrew for consistent CLI tools across distributions

**Categories covered:**
- Development tools and languages
- CLI utilities and system tools  
- Desktop applications (when DE detected)
- Python packages via pip/pipx

### Python Packages

**Traditional Python package management:**
- **Global packages** (via pip): Development tools and libraries
- **Isolated CLI tools** (via pipx): Command-line applications

**Modern Python package management** (faster alternatives):
- **UV packages** (via uv): Fast pip replacement for project dependencies
- **UVX tools** (via uv tool): Fast pipx replacement for CLI applications

**Package categories:**
- Development: black, flake8, mypy, pytest, poetry, ruff
- Utilities: requests, rich, typer, click, httpx
- CLI tools: pre-commit, commitizen, elia-chat, ggshield

## Daily Usage

### Managing Dotfiles

```bash
# Pull latest changes
chezmoi update

# Edit a config file
chezmoi edit ~/.gitconfig

# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Add new file to dotfiles
chezmoi add ~/.config/newapp/config.yaml
```

### Updating Packages

**Cross-platform update tool:**
```bash
# Update all package managers
topgrade
```

**Platform-specific:**
```bash
# Linux
sudo apt update && sudo apt upgrade
brew upgrade

# Windows
winget upgrade --all
scoop update --all
```

## Customization

### Adding New Configuration Files

```bash
# Linux/macOS
chezmoi add ~/.config/newapp/config.yaml

# Windows  
chezmoi add $env:APPDATA/newapp/settings.json
```

### Package Management Customization

Edit the package definition files to add/remove packages:

```yaml
# home/.chezmoidata/pkgs/windows.yml
pkgs:
  windows:
    winget:
      - YourApp.Package

# home/.chezmoidata/pkgs/ubuntu.yml  
pkgs:
  ubuntu:
    apt:
      - your-package
```

### Template Variables

Customize behavior in `home/.chezmoi.toml.tmpl`:

```toml
[data]
# Your custom variables
installScoopPackages = true
terminalFontSize = 14
theme = "dark"
```

## Documentation

- [Chezmoi Usage Guide](docs/CHEZMOI.md) - Understanding file organization and templating
- [UV/UVX Implementation](docs/UV_UVX_README.md) - Modern Python package management setup
- [Pre-commit Setup](docs/pre-commit-setup.md) - Code quality and security automation  
- [Windows Configuration](docs/windows.md) - Windows-specific notes and utilities
- [Linux Configuration](docs/linux.md) - Linux-specific guides and troubleshooting

## Security Features

### Secret Management
- **Bitwarden integration** for sensitive configuration values
- **Age/GPG encryption** for private files
- **SSH key management** with automatic Git signing setup

### Code Quality
- **Pre-commit hooks** with Gitleaks secret detection
- **Automated linting** for shell scripts, markdown, YAML
- **Commit message validation** with conventional commits

## Troubleshooting

### Common Issues

**"Command not found" after installation:**
```bash
# Restart shell or reload PATH
source ~/.bashrc  # Linux
refreshenv        # Windows (if using Chocolatey)
```

**Package installation fails:**
- Check internet connection
- For Windows: Ensure execution policy allows scripts
- For Linux: Check if package manager is up to date

**Bitwarden authentication:**
```bash
# Re-authenticate with Bitwarden
bw login
# Store (or replace) the BWS access token in the OS keystore
bws-token-set
# Headless Linux without a Secret Service: use the environment variable instead
export BWS_ACCESS_TOKEN="your-token"
```

### Getting Help

1. Check the [documentation](docs/) directory
2. Review chezmoi logs: `chezmoi execute-template --debug`
3. Open an issue on GitHub with error details

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [KevinNitroG/dotfiles](https://github.com/KevinNitroG/dotfiles) - Original inspiration
- [Chezmoi](https://www.chezmoi.io/) - Excellent dotfiles management
- [Oh My Posh](https://ohmyposh.dev/) - Beautiful cross-platform prompts
