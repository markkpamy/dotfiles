# UV and UVX Implementation for Chezmoi Dotfiles

This implementation adds support for UV (fast pip replacement) and UVX (fast pipx replacement) to your existing dotfiles setup.

## What was added

### Scripts Created

#### Linux Scripts (Bash)
- `run_once_before_42_install-python-uv.sh.tmpl` - UV package installation
- `run_once_before_43_install-python-uvx.sh.tmpl` - UVX application installation

#### Windows Scripts (PowerShell)
- `run_once_before_42_install-python-uv.ps1.tmpl` - UV package installation
- `run_once_before_43_install-python-uvx.ps1.tmpl` - UVX application installation

### Configuration Updated
- Updated `python.yml` to include `uv` and `uvx` package lists for both Linux and Windows

## UV vs UVX Command Choice

This implementation uses the correct UV commands for persistent tool installation:

### UV Package Manager
- Uses `uv add` for project dependencies
- Uses `uv sync` for environment synchronization
- Equivalent to `pip install` but faster

### UVX Tool Manager  
- Uses `uv tool install` for persistent tool installation
- **NOT** `uvx` (which is for one-off execution only)
- `uv tool install` is equivalent to `pipx install`
- Tools remain available permanently in PATH


### Why `uv tool install` vs `uvx`?

- **`uvx`** = temporary execution (runs tool once in isolated environment)  
- **`uv tool install`** = permanent installation (like `pipx install`)
- **For dotfiles**, we want persistent tools available in PATH, so `uv tool install` is correct

## Features

### UV Package Manager (Fast Pip Replacement)
- ✅ Automatic UV installation check
- ✅ Project initialization if needed
- ✅ Package installation with progress tracking
- ✅ Environment synchronization with `uv sync`
- ✅ Support for complex package specifications (extras, versions)
- ✅ Consistent UI with existing pip script

### UVX Application Manager (Fast Pipx Replacement)  
- ✅ Uses `uv tool install` for persistent installation
- ✅ PATH configuration for tool binaries
- ✅ Force installation (`--force`) to update existing tools
- ✅ Isolated application environments
- ✅ Tools remain available permanently
- ✅ Consistent UI with existing pipx script

## Usage

The scripts will run automatically during chezmoi application based on your configuration:

1. **Enable Python packages** in your chezmoi configuration
2. **UV packages** will be installed if `.pkgs.python.linux.uv` or `.pkgs.python.windows.uv` are configured
3. **UVX applications** will be installed if `.pkgs.python.linux.uvx` or `.pkgs.python.windows.uvx` are configured

## Package Configuration

Edit the package lists in `python.yml`:

```yaml
pkgs:
  python:
    linux:
      uv:
        - 'requests'
        - 'click[dev]'  # With extras
        - 'pydantic>=2.0'  # With version constraint
      uvx:
        - 'black'
        - 'pre-commit'
        - 'ruff'
```

## Installation Order

Scripts run in this order:
1. `40_install-python-pip.sh` (existing)
2. `41_install-python-pipx.sh` (existing)  
3. `42_install-python-uv.sh` (new)
4. `43_install-python-uvx.sh` (new)

This ensures UV is installed after pip but can coexist with both traditional tools.

## Verification Commands

After installation, verify with:

```bash
# Check UV installation
uv --version

# List UV project dependencies  
uv tree

# List installed UVX tools
uv tool list

# Check specific tool
black --version  # Should work if black was installed via uvx
```

## Migration from pip/pipx

You can gradually migrate from pip/pipx to uv/uvx:

1. **Keep existing pip/pipx** for compatibility
2. **Add UV packages** for new project dependencies  
3. **Add UVX tools** for new CLI applications
4. **Eventually remove** pip/pipx entries once satisfied with UV

Both systems can coexist safely in your dotfiles.
