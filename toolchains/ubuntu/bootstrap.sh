#!/bin/bash
# Script: setup_toolchain.sh
# Purpose: Installs essential development tools (zsh, git, jq, curl, wget, chezmoi)
# Designed for robust, idempotent execution in minimal Linux environments.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- 1. Identify Package Manager and Privilege Escalation ---

# Determine the privilege command (sudo)
SUDO_CMD=""
if command -v sudo &> /dev/null; then
    SUDO_CMD="sudo"
fi

# Identify the package manager
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt-get"
    INSTALL_CMD="$SUDO_CMD $PKG_MANAGER install -y"
    UPDATE_CMD="$SUDO_CMD $PKG_MANAGER update"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="$SUDO_CMD $PKG_MANAGER install -y"
    UPDATE_CMD="$SUDO_CMD $PKG_MANAGER check-update" # dnf doesn't always need a full update
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    INSTALL_CMD="$SUDO_CMD $PKG_MANAGER install -y"
    UPDATE_CMD="$SUDO_CMD $PKG_MANAGER check-update"
else
    echo "ERROR: Unsupported package manager. Please install tools manually."
    exit 1
fi

echo "Detected package manager: $PKG_MANAGER"

# --- 2. Install Tools (Idempotent Check) ---

REQUIRED_TOOLS=("zsh" "git" "jq" "curl" "wget")
CHEZMOI_INSTALL_DIR="/usr/local/bin"

# Only run update if necessary (often slow)
if [ "$PKG_MANAGER" != "dnf" ] && [ "$PKG_MANAGER" != "yum" ]; then
    echo "Updating package lists..."
    $UPDATE_CMD
fi

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Installing $tool..."
        $INSTALL_CMD "$tool"
    else
        echo "$tool is already installed."
    fi
done

# --- 3. Install chezmoi (Special case for GitHub download) ---

if ! command -v chezmoi &> /dev/null; then
    echo "Installing chezmoi..."
    # Download the installation script and pipe it to bash
    # -fsSL ensures secure, silent, follow-redirect download
    curl -fsSL https://chezmoi.io/install | sh -s -- -b "$CHEZMOI_INSTALL_DIR"
    echo "chezmoi installed to $CHEZMOI_INSTALL_DIR"
else
    echo "chezmoi is already installed."
fi

# --- 4. Success Message and Next Steps ---

echo "----------------------------------------------------"
echo "✅ Essential toolchain is installed."
echo "Your next step is to configure your shell and dotfiles."
echo "----------------------------------------------------"

# Optional: Set zsh as default shell (requires the user's password for chsh)
# if command -v chsh &> /dev/null && [ "$SHELL" != "$(which zsh)" ]; then
#     echo "To set zsh as your default shell, run: chsh -s \$(which zsh)"
# fi
