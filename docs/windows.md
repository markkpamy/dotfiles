# Windows Dotfiles Configuration

This document covers Windows-specific configuration, package management, and additional tools for the dotfiles setup.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [📦 Package Management](#-package-management)
  - [Automated Installation During Setup](#automated-installation-during-setup)
  - [Package Managers Used](#package-managers-used)
  - [Manual Package Installation](#manual-package-installation)
- [🐍 Python Package Management](#-python-package-management)
  - [What gets installed](#what-gets-installed)
  - [During installation](#during-installation)
  - [Manual installation](#manual-installation)
  - [Package customization](#package-customization)
- [🪟 Windows-Specific Features](#-windows-specific-features)
  - [Window Management](#window-management)
  - [PowerShell Configuration](#powershell-configuration)
  - [Windows Terminal](#windows-terminal)
- [🎈 Additional Software & Tweaks](#-additional-software--tweaks)
  - [Office Suite](#office-suite)
  - [Media & Entertainment](#media--entertainment)
  - [System Utilities](#system-utilities)
  - [Development Tools](#development-tools)
- [⚙️ System Configuration](#️-system-configuration)
  - [Windows Settings](#windows-settings)
  - [Registry Tweaks](#registry-tweaks)
  - [Environment Variables](#environment-variables)
- [📒 Notes & References](#-notes--references)
  - [SSH & GPG Setup](#ssh--gpg-setup)
  - [Browser Configuration](#browser-configuration)
  - [Troubleshooting](#troubleshooting)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

---

## 📦 Package Management

The Windows dotfiles setup includes comprehensive automated package management using multiple package managers.

### Automated Installation During Setup

During `chezmoi apply`, you'll be prompted for package installation:

```
Install Scoop packages? This may take some time [y/N]: 
Install Choco packages? This may take some time [y/N]:
Install Python packages (pip and pipx)? This may take some time [y/N]:
```

- **Recommended**: Answer **Yes** to all for a complete setup
- **Quick setup**: Answer **No** to skip time-consuming installations
- **Selective**: Choose specific package managers based on your needs

### Package Managers Used

#### 🟦 **WinGet** (Always installed)
Core development tools and system applications:
- **Languages**: Git, Python, Node.js (via fnm)
- **Development**: Neovim, Docker Desktop, AWS CLI, Azure CLI
- **CLI Tools**: bat, eza, fd, fzf, ripgrep, delta, lazygit
- **Productivity**: Windows Terminal, PowerToys, Obsidian

#### 🟪 **Scoop** (Optional, prompted)
Portable applications and CLI tools:
- Focus on development tools and utilities
- Installs to user directory (no admin required)
- Easy package management and updates

#### 🍫 **Chocolatey** (Optional, prompted)  
System-wide applications requiring admin privileges:
- Legacy applications not available in WinGet
- System-level software installations

#### 🟨 **PowerShell Gallery** (Always installed)
PowerShell modules for enhanced shell experience:
- `PSReadLine` - Enhanced command line editing
- `Terminal-Icons` - File type icons in terminal
- `posh-git` - Git integration for PowerShell
- `PSFzf` - Fuzzy finder integration

### Manual Package Installation

If you skipped automated installation or want to install specific packages:

```powershell
# Install WinGet packages
winget install Git.Git
winget install Python.Python.3.12
winget install Neovim.Neovim

# Install Scoop
iwr -useb get.scoop.sh | iex
scoop install git python neovim

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install PowerShell modules
Install-Module -Name PSReadLine -Force
Install-Module -Name Terminal-Icons -Force
```

---

## 🐍 Python Package Management

Automated Python package management for development tools and CLI utilities.

### What gets installed

**Via pip** (global Python environment):
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

```powershell
# Ensure Python is installed
winget install Python.Python.3.12

# Install pip packages
python -m pip install --upgrade pip
python -m pip install --user black flake8 mypy pipx

# Install pipx packages
python -m pip install --user pipx
pipx ensurepath
pipx install httpie
pipx install pre-commit
pipx install yt-dlp
```

### Package customization

Edit `home/.chezmoidata/pkgs/python.yml`:

```yaml
pkgs:
  python:
    windows:
      pip:
        - your-package-here
        - another-dev-tool
      pipx:
        - your-cli-tool-here
        - isolated-application
```

---

## 🪟 Windows-Specific Features

### Window Management

**Komorebi** - Advanced tiling window manager:
- Automatic window tiling and workspace management
- Configurable keybindings and rules
- Integration with Windows Terminal and system tray

**Alternative options**:
- **GlazeWM** - Simpler tiling window manager
- **PowerToys FancyZones** - Microsoft's window snapping tool

Configuration location: `home/dot_config/komorebi/`

### PowerShell Configuration

**Enhanced PowerShell profile** with:
- **Oh My Posh** integration for beautiful prompts
- **PSReadLine** for advanced line editing
- **Custom aliases** for Git, Docker, Kubernetes
- **Auto-completion** for various CLI tools
- **Directory navigation** shortcuts

Profile location: `home/Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`

### Windows Terminal

**Unified terminal configuration** featuring:
- **Custom color schemes** and themes
- **Font configuration** (Nerd Fonts support)
- **Profile settings** for PowerShell, Command Prompt, WSL
- **Keybinding customization**

Configuration: `home/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json.tmpl`

---

## 🎈 Additional Software & Tweaks

### Office Suite

**Microsoft Office installation and activation:**

1. **Install Office via OTP Tool:**
   ```powershell
   # Download and run OTP Ladian installer
   # Visit: https://otp.landian.vip/redirect/download.php?type=runtime&arch=x64&site=github
   ```

2. **Activate Office with MAS:**
   ```powershell
   irm https://massgrave.dev/get | iex
   ```

**Wakatime integration for Office:**
- [Word](https://github.com/wakatime/office-wakatime/releases/download/latest/WordSetup.zip)
- [PowerPoint](https://github.com/wakatime/office-wakatime/releases/download/latest/PowerPointSetup.zip)  
- [Excel](https://github.com/wakatime/office-wakatime/releases/download/latest/ExcelSetup.zip)

### Media & Entertainment

**Spotify with SpotX (ad-free):**
```powershell
# Install SpotX with new theme
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -new_theme"

# Alternative mirror
iex "& { $(iwr -useb 'https://spotx-official.github.io/run.ps1') } -m -new_theme"
```

**Media players and tools:**
- **MPC-HC** - Lightweight media player
- **OBS with Background Removal** - Streaming/recording
- **qBittorrent Enhanced** - Torrent client

### System Utilities

**WinRAR license:**
```powershell
# Install WinRAR license (requires admin)
curl https://gist.githubusercontent.com/MuhammadSaim/de84d1ca59952cf1efaa8c061aab81a1/raw/rarreg.key | Out-File -FilePath "C:\Program Files\WinRAR\rarreg.key" -Force
```

**System optimization tools:**
- **Optimizer** - Windows privacy and performance tweaks
- **Winutil** - Chris Titus Windows utility
  ```powershell
  irm https://christitus.com/win | iex
  ```
- **Winaero Tweaker** - Advanced Windows customization

### Development Tools

**Additional development software:**
- **IDM (Internet Download Manager)** with patches
- **Visual C++ Redistributables** - All-in-one package
- **Keystore Explorer** - Java keystore management
- **Cursor/Custom cursors** - Enhanced desktop experience

---

## ⚙️ System Configuration

### Windows Settings

**Essential system tweaks:**

1. **Power & Sleep settings**
   - Configure sleep/hibernate behavior
   - Adjust power plan for performance

2. **Privacy settings**
   - Disable telemetry and tracking
   - Configure app permissions

3. **Time synchronization**
   ```powershell
   # Make Windows use UTC (for dual-boot compatibility)
   reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
   ```

4. **DNS configuration (NextDNS)**
   - IPv4: `103.186.65.82`, `38.60.253.211`
   - IPv6: `2400:6ea0:0:1236::d6e2`, `2606:4700:4700::1111`

5. **Print Screen integration**
   - Enable Snipping Tool on Print Screen

### Registry Tweaks

**Disable Windows features:**
```powershell
# Disable desktop switch animation
vivetool /disable /id:42354458

# Disable Windows Defender (use with caution)
# Configure via Winaero Tweaker

# Disable shortcut arrows
# Configure via Winaero Tweaker
```

### Environment Variables

**Viewing environment variables:**
```powershell
# System variables
[System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)

# User variables  
[System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
```

**Setting environment variables:**
```powershell
# Set system variable (requires admin)
[System.Environment]::SetEnvironmentVariable("VARIABLE_NAME", "value", [System.EnvironmentVariableTarget]::Machine)

# Set user variable
[System.Environment]::SetEnvironmentVariable("VARIABLE_NAME", "value", [System.EnvironmentVariableTarget]::User)
```

---

## 📒 Notes & References

### SSH & GPG Setup

**SSH Keys:**
- Keys are automatically managed by chezmoi
- Git is configured for SSH signing
- OpenSSH integration with Windows

**GPG Configuration:**
```powershell
# Import GPG keys (handled automatically by scripts)
gpg --import public-key.asc

# Start GPG agent (configure via Task Scheduler)
gpgconf --launch gpg-agent
gpgconf --launch keyboxd

# Trust imported keys
gpg --edit-key your-key-id
# > trust
# > 5 (ultimate trust)
# > quit
```

### Browser Configuration

**Chrome/Brave flags optimization:**
- Configuration files in `dot_config/`
- Hardware acceleration settings
- Privacy and security tweaks

**Extensions for sideloading:**
- [AltNumberTab](https://github.com/pointtonull/AltNumberTab) - Better tab switching
- [Bypass Paywalls](https://github.com/iamadamdev/bypass-paywalls-chrome) - Paywall remover
- [Useful Scripts](https://github.com/HoangTran0410/useful-script) - Various utilities

**Fixing Brave installed via Scoop:**
1. Open Registry Editor
2. Navigate to: `Computer\HKEY_CURRENT_USER\Software\Classes\BraveFile\shell\open\command`
3. Update command path to Scoop installation directory

### Troubleshooting

**Common issues and solutions:**

1. **PowerShell execution policy:**
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **PATH not updated after installation:**
   ```powershell
   refreshenv  # If using Chocolatey
   # Or restart PowerShell/Command Prompt
   ```

3. **Package installation fails:**
   - Check internet connection
   - Ensure package manager is up to date
   - Try running as administrator if needed

4. **VHD/VHDX optimization (for WSL):**
   ```cmd
   diskpart
   select vdisk file="C:\path\to\file.vhdx"
   attach vdisk readonly
   compact vdisk
   detach vdisk
   exit
   ```

**Default Windows environment variables:**

| Variable | Path |
|----------|------|
| `APPDATA` | `C:\Users\%USERNAME%\AppData\Roaming` |
| `LOCALAPPDATA` | `C:\Users\%USERNAME%\AppData\Local` |
| `USERPROFILE` | `C:\Users\%USERNAME%` |
| `PROGRAMFILES` | `C:\Program Files` |
| `PROGRAMFILES(X86)` | `C:\Program Files (x86)` |
| `TEMP` / `TMP` | `C:\Users\%USERNAME%\AppData\Local\Temp` |

**Useful Windows shortcuts:**
- Program shortcuts: `%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs`
- Shell commands: `shell:startup`, `shell:sendto`, etc.
- CLSID shortcuts: `shell:::{GUID}` for direct access to Control Panel items

**Additional resources:**
- [Windows datetime formats](https://help.scribesoft.com/scribe/en/sol/general/datetime.htm)
- [CLSID shortcuts reference](https://www.tenforums.com/tutorials/3123-clsid-key-guid-shortcuts-list-windows-10-a.html)
- [Shell commands list](https://www.tenforums.com/tutorials/3109-shell-commands-list-windows-10-a.html)

---

**Recommended wallpapers:**
- [Minimalistic Wallpaper Collection](https://github.com/DenverCoder1/minimalistic-wallpaper-collection)

**File management:**
- Symlink git directories: `New-Item -Path gits -ItemType SymbolicLink -Value E:\Git-Repo`
- Change default folder locations (Downloads, Desktop, etc.)
- Configure folder ownership after major Windows updates