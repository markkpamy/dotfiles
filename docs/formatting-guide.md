# Chezmoi Scripts Formatting Guide

This guide explains how to use the formatting libraries in your chezmoi scripts for consistent, beautiful output.

## Quick Start

### For Shell Scripts (Linux/Unix)
```bash
#!/bin/bash
# Import the formatting library
source "{{ .chezmoi.sourceDir }}/.chezmoitemplates/shell/formatting.sh"

# Optional: Setup automatic error handling
setup_error_trap

# Start your script
print_header "Script Name" "Description of what this script does" "$ICON_PACKAGE"

# Your script content here
print_success "Script completed successfully!"

print_footer "Script Name" "completed"
```

### For PowerShell Scripts (Windows)
```powershell
# Import the formatting library
. "{{ .chezmoi.sourceDir }}\.chezmoitemplates\powershell\formatting.ps1"

# Start your script
Write-Header "Script Name" "Description of what this script does" $script:Icons.Package

# Your script content here
Write-Success "Script completed successfully!"

Write-Footer "Script Name" "completed"
```

## Available Functions

### Headers and Sections

| Function | Purpose | Example |
|----------|---------|---------|
| `print_header` / `Write-Header` | Main script header | `print_header "Package Installation" "Installing system packages" "$ICON_PACKAGE"` |
| `print_section` / `Write-Section` | Section divider | `print_section "Docker Setup" "$ICON_DOCKER"` |
| `print_step` / `Write-Step` | Numbered steps | `print_step 1 "Installing dependencies"` |
| `print_footer` / `Write-Footer` | Script completion summary | `print_footer "Script Name" "completed"` |

### Status Messages

| Function | Purpose | Icon | Color |
|----------|---------|------|-------|
| `print_success` / `Write-Success` | Success messages | ✅ | Green |
| `print_error` / `Write-ErrorFormatted` | Error messages | ❌ | Red |
| `print_warning` / `Write-Warning` | Warning messages | ⚠️ | Yellow |
| `print_info` / `Write-Info` | Information messages | ℹ️ | Cyan |
| `print_skipped` / `Write-Skipped` | Skipped operations | ⚠️ | Yellow |

### Actions and Progress

| Function | Purpose | Example |
|----------|---------|---------|
| `print_action` / `Write-Action` | Action being performed | `print_action "Installing" "git" "$ICON_PACKAGE"` |
| `print_progress` / `Write-Progress` | Progress bar | `print_progress 5 10 "Installing package 5 of 10"` |

### Utility Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `check_command` / `Test-CommandAvailable` | Check if command exists | `check_command "git" "Git"` |
| `track_time` / `Measure-ActionTime` | Time an operation | `track_time "Build process" make build` |
| `set_total_steps` / `Set-TotalSteps` | Set total steps for summary | `set_total_steps 5` |

## Available Icons

| Icon | Variable | Usage |
|------|----------|-------|
| 📦 | `$ICON_PACKAGE` / `$script:Icons.Package` | Package management |
| ⬇️ | `$ICON_DOWNLOAD` / `$script:Icons.Download` | Downloads |
| 🔧 | `$ICON_INSTALL` / `$script:Icons.Install` | Installations |
| ⚙️ | `$ICON_CONFIG` / `$script:Icons.Config` | Configuration |
| 🔍 | `$ICON_CHECK` / `$script:Icons.Check` | Checking/Verification |
| ✅ | `$ICON_SUCCESS` / `$script:Icons.Success` | Success |
| ❌ | `$ICON_ERROR` / `$script:Icons.Error` | Errors |
| ⚠️ | `$ICON_WARNING` / `$script:Icons.Warning` | Warnings |
| ℹ️ | `$ICON_INFO` / `$script:Icons.Info` | Information |
| 🔄 | `$ICON_UPDATE` / `$script:Icons.Update` | Updates |
| 🍺 | `$ICON_BREW` / `$script:Icons.Brew` | Homebrew |
| 🐍 | `$ICON_PYTHON` / `$script:Icons.Python` | Python |
| 🐳 | `$ICON_DOCKER` / `$script:Icons.Docker` | Docker |
| 🪟 | N/A / `$script:Icons.Windows` | Windows (PowerShell only) |
| 💙 | N/A / `$script:Icons.PowerShell` | PowerShell (PowerShell only) |

## Color Codes (Shell Scripts)

| Color | Variable | Usage |
|-------|----------|-------|
| Red | `$RED` | Errors |
| Green | `$GREEN` | Success |
| Yellow | `$YELLOW` | Warnings |
| Blue | `$BLUE` | Sections |
| Purple | `$PURPLE` | Headers |
| Cyan | `$CYAN` | Information |
| White | `$WHITE` | Steps |
| Gray | `$GRAY` | Secondary text |
| Reset | `$NC` | Reset color |

## Example Usage Patterns

### Simple Package Installation
```bash
print_header "Package Installation" "Installing required packages"

packages=("git" "curl" "wget")
for i in "${!packages[@]}"; do
    print_progress $((i+1)) ${#packages[@]} "Installing: ${packages[$i]}"
    sudo apt install -y "${packages[$i]}"
done

print_success "All packages installed successfully"
```

### Error Handling with Retry
```bash
install_with_retry() {
    local package="$1"
    local max_attempts=3

    for attempt in $(seq 1 $max_attempts); do
        print_action "Installing" "$package (attempt $attempt/$max_attempts)" "$ICON_PACKAGE"

        if sudo apt install -y "$package"; then
            print_success "$package installed successfully"
            return 0
        else
            print_warning "Attempt $attempt failed for $package"
        fi
    done

    print_error "Failed to install $package after $max_attempts attempts"
    return 1
}
```

### Configuration with Validation
```bash
configure_setting() {
    local setting="$1"
    local value="$2"

    print_action "Configuring" "$setting" "$ICON_CONFIG"

    # Apply configuration
    echo "$setting=$value" >> config.conf

    # Validate
    if grep -q "$setting=$value" config.conf; then
        print_success "$setting configured successfully"
    else
        print_error "Failed to configure $setting"
        return 1
    fi
}
```

## Best Practices

1. **Always use headers and footers** for script boundaries
2. **Include descriptive messages** in print_action calls
3. **Use appropriate icons** for different types of operations
4. **Set total steps** when you know the number of operations
5. **Handle errors gracefully** with clear error messages
6. **Provide meaningful progress updates** for long-running operations
7. **Use sections** to group related operations
8. **Include timing information** for performance-critical operations

## Testing

Use the provided test scripts to see all formatting options:
- Linux: `home/utils-linux/test-formatting.sh`
- Windows: `home/utils-windows/Test-Formatting.ps1`

These scripts demonstrate all available functions and their output.
