# Unified Dotfiles with Chezmoi

This document explains how the unified dotfiles are organized and how they work with chezmoi.

## File Structure

The following files have been created or modified:

1. **Git Configuration**:
   - `private_dot_gitconfig.tmpl`: Unified Git configuration for both Linux and Windows

2. **Windows Terminal Settings**:
   - `private_AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json.tmpl`: Windows Terminal settings

3. **PowerShell Profile**:
   - `private_Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`: PowerShell profile settings

4. **PowerShell Aliases**:
   - `dot_config/git-windows-aliases.ps1`: Git, Kubernetes, Docker, and Flux aliases for PowerShell

5. **Oh My Posh Theme**:
   - `private_dot_oh-my-posh.json.tmpl`: Oh My Posh theme configuration

## Chezmoi Naming Conventions

Chezmoi uses special naming conventions to determine where files should be placed:

- `private_`: Files that should be private (0600 permissions) and placed in the exact path specified (minus the prefix)
- `dot_`: Files that should be placed in the home directory with a `.` prefix
- `.tmpl`: Files that should be processed as templates, with values from `.chezmoi.toml` inserted

## How This Works

When you run `chezmoi apply`, chezmoi will:

1. Process any templates, substituting values from `.chezmoi.toml`
2. Place files in their correct locations, with appropriate permissions
3. For example, `private_dot_gitconfig.tmpl` will become `~/.gitconfig`

## No Manual Steps Required

This configuration eliminates the need for manual symbolic links or file copying. Everything is managed automatically by chezmoi, with OS-specific settings applied based on the current platform.

## Usage

1. Add these files to chezmoi:
   ```
   chezmoi add .
   ```

2. Apply the changes:
   ```
   chezmoi apply
   ```

3. That's it! Your configuration will be consistent across all your systems.
