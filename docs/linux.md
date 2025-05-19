# Linux Dotfiles Configuration

This document covers Linux-specific configuration, package management, and utilities for the dotfiles setup.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [📦 Package Management](#-package-management)
  - [Distribution Support](#distribution-support)
  - [Package Categories](#package-categories)
  - [Desktop Environment Detection](#desktop-environment-detection)
- [🐍 Python Package Management](#-python-package-management)
  - [What gets installed](#what-gets-installed)
  - [During installation](#during-installation)
  - [Manual installation](#manual-installation)
  - [Package customization](#package-customization)
- [🐧 Linux-Specific Features](#-linux-specific-features)
  - [Shell Configuration](#shell-configuration)
  - [Desktop Environment Support](#desktop-environment-support)
  - [System Services](#system-services)
- [🛠️ Development Tools & CLI Utilities](#️-development-tools--cli-utilities)
  - [Core Development Tools](#core-development-tools)
  - [Container & Kubernetes Tools](#container--kubernetes-tools)
  - [CLI Productivity Tools](#cli-productivity-tools)
- [⚙️ System Configuration](#️-system-configuration)
  - [Fonts & Theming](#fonts--theming)
  - [System Services Setup](#system-services-setup)
  - [Desktop Customization](#desktop-customization)
- [📒 Notes & References](#-notes--references)
  - [Distribution-Specific Notes](#distribution-specific-notes)
  - [Browser Configuration](#browser-configuration)
  - [Troubleshooting](#troubleshooting)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

---

## 📦 Package Management

The Linux dotfiles setup provides automated package management across multiple distributions with intelligent detection and installation.

### Distribution Support

**Supported distributions:**
- **Ubuntu/Debian** - APT package manager + Snap/Flatpak for desktop apps
- **Arch/Manjaro** - Pacman + AUR helpers + Flatpak
- **Fedora** - DNF + Flatpak integration
- **Universal** - Homebrew for consistent CLI tools across all distributions

### Package Categories

**Base system packages:**
- Development tools (git, build-essential, etc.)
- System utilities (curl, wget, nano, etc.)
- Shell environments (bash, fish, zsh)

**Desktop packages** (when desktop environment detected):
- Media codecs and players
- Graphics tools and utilities
- Development IDEs and editors
- Productivity applications

**CLI development tools** (via Homebrew):
- Modern CLI replacements (bat, eza, fd, ripgrep)
- Development tools (delta, lazygit, gh)
- System monitoring (htop, btop, fastfetch)

### Desktop Environment Detection

The system automatically detects your desktop environment and installs appropriate packages:

**Supported desktop environments:**
- **GNOME** - Extensions, themes, and GNOME-specific tools
- **KDE/Plasma** - Plasma widgets and KDE applications
- **XFCE** - XFCE panel plugins and utilities
- **Cinnamon** - Cinnamon-specific tools
- **i3/Sway** - Tiling window manager configurations
- **Other** - Generic desktop tools for unsupported DEs

**Detection methods:**
1. `XDG_CURRENT_DESKTOP` environment variable
2. `DESKTOP_SESSION` fallback
3. Process detection for window managers

---

## 🐍 Python Package Management

This dotfiles setup includes automated Python package installation via pip and pipx for Linux systems.

### What gets installed

**Via system package manager:**
- **Ubuntu/Debian**: `python3`, `python3-pip`, `python3-venv`
- **Arch/Manjaro**: `python`, `python-pip`
- **Fedora**: `python3`, `python3-pip`
- **Homebrew**: `python` (automatically handled)

**Via pip** (user-level installation):
- **Development tools**: black, flake8, mypy, isort, autopep8, pylint, bandit
- **Package management**: pipx, virtualenv, pipenv, poetry  
- **CLI utilities**: requests, rich, typer, click
- **Testing**: pytest, pytest-cov, tox
- **Documentation**: mkdocs, sphinx

**Via pipx** (isolated environments):
- **CLI applications**: httpie, yt-dlp, pre-commit, cookiecutter
- **Tools**: ansible, speedtest-cli, thefuck, tldr, pip-autoremove

### During installation

Prompt: `Install Python packages (pip and pipx)? This may take some time`

- **Yes**: Installs all Python packages automatically (~5-10 minutes)
- **No**: Skips Python package installation (can install manually later)

### Manual installation

**For Ubuntu/Debian:**
```bash
# Install system Python packages
sudo apt update
sudo apt install python3 python3-pip python3-venv

# Install pip packages
python3 -m pip install --user --upgrade pip
python3 -m pip install --user black flake8 mypy pipx

# Install pipx packages  
pipx ensurepath
pipx install httpie
pipx install pre-commit
```

**For Arch/Manjaro:**
```bash
# Install system Python packages
sudo pacman -S python python-pip

# Install pip packages
python -m pip install --user --upgrade pip
python -m pip install --user black flake8 mypy pipx

# Install pipx packages
pipx ensurepath
pipx install httpie
pipx install pre-commit
```

### Package customization

Edit the shared Python configuration file:

**Configuration**: `home/.chezmoidata/pkgs/python.yml`
```yaml
pkgs:
  python:
    linux:
      pip:
        - your-package-here
        - development-tool
      pipx:
        - your-cli-tool-here
        - isolated-application
```

---

## 🐧 Linux-Specific Features

### Shell Configuration

**Bash** (`dot_bashrc.tmpl`):
- Enhanced prompt with Git integration
- Custom aliases and functions
- History optimization
- Completion enhancements

**Fish** (`dot_config/fish/`):
- Custom functions and abbreviations
- Plugin management via Fisher
- Enhanced completion system
- Syntax highlighting

**Zsh** (auto-detected):
- Oh My Zsh integration
- Custom themes and plugins
- Enhanced completion

### Desktop Environment Support

**GNOME**:
- GNOME Shell extensions
- dconf settings automation
- Keyboard shortcuts
- Theme customization

**KDE/Plasma**:
- Plasma configuration management
- KDE application preferences
- Widget and panel customization
- Keyboard shortcuts and effects

**i3/Sway**:
- Tiling window manager configuration
- Status bar setup (i3status, waybar)
- Workspace management
- Application launcher integration

### System Services

**Systemd integration**:
- Custom user services
- Timer-based automation
- Service management scripts
- Boot-time configuration

**Example services**:
- Rclone mounting for cloud storage
- Automatic backup scripts
- Development environment initialization

---

## 🛠️ Development Tools & CLI Utilities

### Core Development Tools

**Version control**:
- Git with enhanced configuration
- GitHub CLI integration
- Delta for better diffs
- Lazygit for GUI management

**Text editors**:
- Neovim with comprehensive configuration
- Micro as lightweight alternative
- Helix for modern editing experience

**Build tools**:
- Make, CMake, Ninja
- GCC, Clang toolchains
- Development libraries and headers

### Container & Kubernetes Tools

**Container management**:
- Docker with rootless configuration
- Podman as Docker alternative
- Docker Compose for orchestration

**Kubernetes ecosystem**:
- kubectl with auto-completion
- k9s for cluster management
- Helm for package management
- Flux for GitOps workflows

### CLI Productivity Tools

**File management**:
- `eza` - Modern ls replacement with icons
- `fd` - Fast and user-friendly find alternative
- `ripgrep` - Ultra-fast text search
- `bat` - Cat with syntax highlighting
- `yazi` - Terminal file manager

**System monitoring**:
- `btop` - Resource monitor
- `dust` - Disk usage analyzer
- `bottom` - System monitor
- `fastfetch` - System information

**Network tools**:
- `httpie` - User-friendly HTTP client
- `curlie` - Curl with httpie syntax
- `gping` - Ping with graph
- `bandwhich` - Network utilization monitor

---

## ⚙️ System Configuration

### Fonts & Theming

**Nerd Fonts installation**:
- JetBrains Mono Nerd Font (primary)
- Fira Code Nerd Font (alternative)
- Font configuration for terminal applications

**Theme management**:
- Oh My Posh for unified prompts
- Starship as alternative prompt
- Consistent color schemes across terminals

### System Services Setup

**Automatic service configuration**:
```bash
# Rclone mount service example
systemctl --user enable rclone@remote-name
systemctl --user start rclone@remote-name
```

**Service management utilities**:
```bash
# Clean failed services
systemctl reset-failed

# Check service status
systemctl --user status service-name
```

### Desktop Customization

**GNOME customization**:
- Extension auto-installation
- dconf settings import
- Custom keybindings
- Theme application

**KDE customization**:
- Plasma configuration files
- Widget management
- Global themes
- Activity setup

**File associations**:
```bash
# Set default applications
xdg-settings set default-web-browser firefox.desktop
xdg-mime default firefox.desktop text/html
```

---

## 📒 Notes & References

### Distribution-Specific Notes

**Ubuntu/Debian**:
- PPAs for latest software versions
- Snap package management
- Flatpak integration via Flathub
- Backport repositories

**Arch/Manjaro**:
- AUR helper installation (yay/paru)
- Pacman hooks for automation
- Custom repository management
- Kernel selection

**Fedora**:
- DNF package configuration
- Flatpak first-party support
- RPM Fusion repositories
- Toolbox container management

### Browser Configuration

**Firefox/Brave customization**:
- User.js for privacy settings
- Custom CSS for interface
- Extension management
- Profile synchronization

**Brave-specific configuration**:
- Shield settings optimization
- Custom filter lists:
  ```
  https://abpvn.com/vip/kev.txt?ublock
  https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt
  https://raw.githubusercontent.com/bogachenko/fuckfuckadblock/master/fuckfuckadblock.txt
  ```

### Troubleshooting

**Common issues and solutions**:

1. **Fonts not appearing correctly**:
   ```bash
   # Rebuild font cache
   fc-cache -fv
   
   # Check font installation
   fc-list | grep "Font Name"
   ```

2. **Shell not changing**:
   ```bash
   # Change default shell
   chsh -s $(which fish)
   # Or for zsh
   chsh -s $(which zsh)
   ```

3. **Desktop applications not appearing**:
   ```bash
   # Update desktop database
   update-desktop-database ~/.local/share/applications
   ```

4. **Flatpak/Snap issues**:
   ```bash
   # Flatpak permissions
   flatpak permission-reset
   
   # Snap refresh
   sudo snap refresh
   ```

**System utilities**:

**Arch installation helpers**:
```bash
# Set larger font for installation
setfont ter-132n
```

**Fingerprint setup** (for supported devices):
```bash
# Install and configure fprintd
sudo pacman -S fprintd
sudo fprintd-enroll username
```

**XDG configuration**:
```bash
# Set default browser
xdg-settings set default-web-browser brave-browser.desktop

# Set MIME associations
xdg-mime default brave-browser.desktop x-scheme-handler/http
xdg-mime default brave-browser.desktop x-scheme-handler/https
```

**Tmux utilities**:
```bash
# Attach to session with new directory
tmux attach-session -t . -c /path/to/new/directory
```

**Performance tips**:
- Use `systemd-analyze` to check boot times
- Configure `systemd-resolved` for DNS
- Enable `zswap` for better memory management
- Use `iotop` and `iftop` for I/O monitoring

**Security considerations**:
- Configure UFW/firewalld for firewall
- Set up fail2ban for SSH protection
- Use AppArmor/SELinux profiles
- Regular system updates via automation

---

**Additional resources**:
- [Arch Wiki](https://wiki.archlinux.org/) - Comprehensive Linux documentation
- [DistroWatch](https://distrowatch.com/) - Distribution information
- [Flathub](https://flathub.org/) - Flatpak application repository
- [AUR](https://aur.archlinux.org/) - Arch User Repository

**Hardware-specific notes**:
- ThinkPad laptops: Install `tlp` for power management
- NVIDIA graphics: Use proprietary drivers via distribution repos
- Audio: PipeWire recommended for modern audio stack
- Bluetooth: `bluez` and `bluez-utils` for device management