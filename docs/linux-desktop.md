# Linux Desktop Configuration

This document covers how desktop environments are detected and configured in this dotfiles repository, as well as how desktop packages are installed.

## Supported Desktop Environments

- GNOME
- KDE Plasma
- Xfce
- Cinnamon
- MATE
- i3 (Window Manager)
- Sway (Wayland Window Manager)
- Other tiling window managers (awesome, bspwm, dwm, xmonad)

## Desktop Detection

Desktop detection happens during chezmoi initialization through `.chezmoi.toml.tmpl`. The detection works as follows:

1. **Primary Method**:
   - Checks for `$XDG_CURRENT_DESKTOP` environment variable
   - Maps it to a standard desktop environment name (gnome, kde, xfce, etc.)

2. **Secondary Method**:
   - If `$XDG_CURRENT_DESKTOP` is not set, checks `$DESKTOP_SESSION` environment variable
   - Maps it to a standard desktop environment name

3. **Fallback Detection**:
   - Checks for display server environment variables (`$DISPLAY`, `$WAYLAND_DISPLAY`)
   - Prompts the user to select their desktop environment if running interactively

The detection results are stored in chezmoi's data, making them available to all templates and scripts.

## Desktop Packages

Desktop packages are defined in `~/.chezmoidata/pkgs/linux-desktop.yaml` and are organized by:

- **Common packages** installed on all desktop systems
- **Desktop-specific packages** for GNOME, KDE, Xfce, etc.
- **Category packages**:
  - Themes and appearance
  - Fonts
  - Utilities
  - Multimedia applications
  - Development tools
  - Productivity applications
  - Communication apps

Additionally, Flatpak and Snap support is included for cross-distribution package installation.

## Installation Process

When you run `chezmoi apply` on a Linux desktop system, the following happens:

1. **Desktop Detection**: During initialization, chezmoi detects if you're running on a desktop and which environment
2. **Package Installation**:
   - Distribution-specific packages are installed via the native package manager
   - Desktop environment-specific packages are installed
   - Category-specific packages are installed
3. **Flatpak/Snap Installation**: Additional applications are installed via Flatpak and/or Snap
4. **Configuration**: Desktop environment settings are configured

## Distribution Support

The system supports multiple Linux distributions:

- **Debian/Ubuntu**: Using apt package manager
- **Arch Linux**: Using pacman (with optional AUR support via yay)
- **Fedora/RHEL**: Using dnf package manager (with RPM Fusion)

## Customizing Package Selection

To add or remove packages:

1. Edit the `~/.chezmoidata/pkgs/linux-desktop.yaml` file
2. Run `chezmoi apply` to apply changes

Example for adding a new application to the common packages:

```yaml
pkgs:
  linux-desktop:
    common:
      - existing-package1
      - existing-package2
      - your-new-package  # Add your package here
```

## Custom Configuration

Desktop environment configurations are handled by the `run_once_after_10-configure-desktop-env.sh.tmpl` script, which applies settings based on the detected desktop environment.

### GNOME Configuration

The script configures GNOME settings using `gsettings`, including:
- Dark theme preference
- Font settings
- Window management behavior
- File manager preferences

### KDE Configuration

For KDE, the script configures:
- Dolphin file manager
- Window management behavior
- Theme settings

### Xfce Configuration

For Xfce, various settings are configured via `xfconf-query`.

## Forcing a Desktop Environment

If desktop detection fails or you want to force a specific desktop environment:

```bash
# Create or edit ~/.config/chezmoi/chezmoi.toml manually
[data]
    isDesktop = true
    desktopEnv = "gnome" # or kde, xfce, etc.
```

## Troubleshooting

If you encounter issues with desktop detection or package installation:

1. **Verify Detection**: Check if the desktop environment variables are set correctly:
   ```bash
   echo $XDG_CURRENT_DESKTOP
   echo $DESKTOP_SESSION
   ```

2. **Force Desktop Mode**: Edit your `~/.config/chezmoi/chezmoi.toml` as shown above

3. **Package Issues**: Check the package names in your distribution and modify the `linux-desktop.yaml` file accordingly

4. **Debugging**: Run chezmoi with verbose output:
   ```bash
   chezmoi apply -v
   ```

5. **Skip Desktop Installation**: If you want to skip desktop packages, you can set `isDesktop = false` in your `~/.config/chezmoi/chezmoi.toml` file.

## Notes on Specific Distributions

### Ubuntu/Linux Mint

These distributions use Apt for package management and have good support for both Snap and Flatpak. The script automatically handles installing the right packages.

### Arch Linux

For Arch-based systems, packages are installed via pacman. The script checks for yay to install AUR packages. If you don't have yay installed but want AUR packages, you should install it first.

### Fedora

Fedora uses DNF and has good Flatpak support. The script automatically adds RPM Fusion repositories for additional packages if they're not already enabled.
