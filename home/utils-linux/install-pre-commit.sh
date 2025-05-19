#!/bin/bash
# Install and configure pre-commit

set -e

echo "Setting up pre-commit framework..."

# Detect OS and install accordingly
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux system"

    # Install pre-commit via pip (most reliable method)
    if command -v pip3 &> /dev/null; then
        echo "Installing pre-commit via pip3..."
        pip3 install --user pre-commit
    elif command -v pip &> /dev/null; then
        echo "Installing pre-commit via pip..."
        pip install --user pre-commit
    elif command -v apt &> /dev/null; then
        echo "Installing pre-commit via apt..."
        sudo apt update
        sudo apt install -y pre-commit
    elif command -v brew &> /dev/null; then
        echo "Installing pre-commit via Homebrew..."
        brew install pre-commit
    else
        echo "Installing pre-commit via curl..."
        curl https://pre-commit.com/install-local.py | python3 -
    fi

elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS system"
    if command -v brew &> /dev/null; then
        echo "Installing pre-commit via Homebrew..."
        brew install pre-commit
    else
        echo "Installing pre-commit via pip..."
        pip3 install --user pre-commit
    fi

else
    echo "Installing pre-commit via pip..."
    pip3 install --user pre-commit
fi

# Make sure pre-commit is in PATH
if ! command -v pre-commit &> /dev/null; then
    echo "Adding pre-commit to PATH..."
    export PATH="$HOME/.local/bin:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

echo "Pre-commit installation completed!"

# Verify installation
if command -v pre-commit &> /dev/null; then
    echo "✅ Pre-commit successfully installed!"
    pre-commit --version
else
    echo "❌ Pre-commit installation failed!"
    exit 1
fi

echo ""
echo "Setting up pre-commit in Git repositories..."
echo "Run 'pre-commit install' in each Git repository where you want to use pre-commit."
echo "Or run 'pre-commit install --install-hooks -t pre-commit -t commit-msg' for full setup."
