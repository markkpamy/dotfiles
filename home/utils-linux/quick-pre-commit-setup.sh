#!/bin/bash
# Quick setup script to initialize pre-commit in a new repository

set -e

echo "🚀 Quick Pre-commit Setup Script"
echo "================================"

# Check if we're in a Git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a Git repository. Initializing one..."
    read -p "Initialize Git repository here? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git init
        echo "✅ Git repository initialized"
    else
        echo "❌ Exiting. Please run this script in a Git repository."
        exit 1
    fi
fi

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "❌ Pre-commit not found. Installing..."

    # Try different installation methods
    if command -v pip3 &> /dev/null; then
        pip3 install --user pre-commit
    elif command -v brew &> /dev/null; then
        brew install pre-commit
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y pre-commit
    else
        echo "❌ Unable to install pre-commit automatically."
        echo "Please install pre-commit manually: https://pre-commit.com/#install"
        exit 1
    fi
fi

# Copy pre-commit config if it exists in home directory
if [ -f "$HOME/.pre-commit-config.yaml" ]; then
    echo "📋 Copying pre-commit config from home directory..."
    cp "$HOME/.pre-commit-config.yaml" .
elif [ ! -f ".pre-commit-config.yaml" ]; then
    echo "📝 Creating basic pre-commit config..."
    cat > .pre-commit-config.yaml << 'EOF'
# Basic pre-commit configuration
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.2
    hooks:
      - id: gitleaks
EOF
fi

# Install hooks
echo "🔧 Installing pre-commit hooks..."
pre-commit install --install-hooks
pre-commit install --hook-type commit-msg

# Optional: Run on all files
read -p "🔍 Run pre-commit on all existing files? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🏃 Running pre-commit on all files..."
    pre-commit run --all-files
fi

echo ""
echo "✅ Pre-commit setup completed successfully!"
echo ""
echo "📝 Next steps:"
echo "• Pre-commit will now run automatically on each commit"
echo "• Configure .pre-commit-config.yaml to add/remove hooks"
echo "• Run 'pre-commit run --all-files' to check all files"
echo "• Run 'pre-commit autoupdate' to update hook versions"
echo ""
echo "Happy coding! 🎉"
