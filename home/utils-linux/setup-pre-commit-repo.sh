#!/bin/bash
# Set up pre-commit in the current Git repository

set -e

# Check if we're in a Git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a Git repository!"
    echo "Please run this script from within a Git repository."
    exit 1
fi

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "❌ Error: pre-commit is not installed!"
    echo "Please install pre-commit first by running: ./utils-linux/install-pre-commit.sh"
    exit 1
fi

echo "Setting up pre-commit in this repository..."

# Install pre-commit Git hooks
echo "Installing pre-commit Git hooks..."
pre-commit install --install-hooks

# Install commit-msg hook for commitizen (if using)
echo "Installing commit-msg hook..."
pre-commit install --hook-type commit-msg

# Install pre-push hook
echo "Installing pre-push hook..."
pre-commit install --hook-type pre-push

# Optionally run pre-commit on all files
read -p "Run pre-commit on all files? This may take some time. (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running pre-commit on all files..."
    pre-commit run --all-files
fi

echo "✅ Pre-commit setup completed!"
echo ""
echo "📝 What happens now:"
echo "- Pre-commit hooks will run automatically before each commit"
echo "- To manually run all hooks: pre-commit run --all-files"
echo "- To update hooks: pre-commit autoupdate"
echo "- To bypass hooks (not recommended): git commit --no-verify"
