#!/bin/bash

# Exit if the target Brewfile was not modified in the current Chezmoi run.
# This ensures we don't unnecessarily run brew bundle every time.
# Test if the file exists and is not empty
if command -v brew >/dev/null 2>&1 && [ -s ~/.Brewfile ]; then
    # 1. Update Homebrew Packages
    echo "Running 'brew bundle' to ensure all packages are installed..."
    brew bundle --global

    # --- 2. Initialize Version Managers ---
    
    # 2a. Rustup: Run the official installer if not already installed
    if ! command -v rustup >/dev/null 2>&1; then
        echo "Installing Rustup (Official Rust Installer)..."
        # Run the installer, accept defaults, and suppress output
        # The installer will set up PATH, etc., in your Zsh profile files
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &> /dev/null
    fi

    # 2b. Pyenv: Initialize pyenv for use
    if command -v pyenv >/dev/null 2>&1; then
        echo "Initializing pyenv..."
        # This is typically needed once to ensure the pyenv shims are set up
        eval "$(pyenv init --path)"
        # Use pyenv to install a default Python version
        if ! pyenv versions --bare | grep -q "3.12"; then
             echo "Installing default Python 3.12.x via pyenv (This may take a minute)..."
             # Use a specific version you want as default
             pyenv install 3.12 &> /dev/null 
             pyenv global 3.12
        fi
    fi
    
    # 2c. Goenv: Initialize goenv for use
    if command -v goenv >/dev/null 2>&1; then
        echo "Initializing goenv..."
        eval "$(goenv init --path)"
        # Optionally install a default Go version here as well
    fi
    
    echo "Homebrew packages and version managers initialized."
fi