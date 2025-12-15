#!/bin/bash
# file: .chezmoi.d/run_onetime_install_zsh.sh
# Runs once to install Zsh and Oh My Zsh if they are not already present.

# Exit immediately if a command exits with a non-zero status.
set -e

ZSH_CUSTOM_DIR="$HOME/.oh-my-zsh"

# --- 1. Install Zsh Package (System Dependency) ---

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "Zsh not found. Attempting installation..."

    # Check for sudo. If it exists, use it. If not, try apt directly (as root)
    if command -v sudo &> /dev/null; then
        SUDO_CMD="sudo"
    else
        SUDO_CMD=""
    fi

    # Use the determined command prefix
    $SUDO_CMD apt update
    $SUDO_CMD apt install -y zsh

    if [ $? -ne 0 ]; then
        echo "ERROR: Zsh installation failed. Check container permissions."
        exit 1
    fi
fi

# --- 2. Install Oh My Zsh ---

# Check if oh-my-zsh is already cloned
if [ ! -d "$ZSH_CUSTOM_DIR" ]; then
    echo "Oh My Zsh not found. Cloning repository..."

    # Use curl to get the installation script and pipe to bash
    # Note: Using the official OMZ method here.
    if ! command -v git &> /dev/null; then
      echo "Git not found. Please install git first."
      exit 1
    fi

    # Clone the repository directly
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_CUSTOM_DIR"

    echo "Oh My Zsh installation complete."
fi

# --- 3. Set Zsh as Default Shell (Optional) ---
# Check if the current user's default shell is zsh
if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
    echo "Setting Zsh as the default shell (requires sudo)."
    # Replace the current user's shell (requires sudo)
    sudo chsh -s "$(which zsh)" "$(whoami)"
fi

# IMPORTANT: Ensure chezmoi deletes this script after success.
# To ensure it only runs once, you must tell chezmoi to remove it.
exit 0
