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

REQUIRED_TOOLS=("zsh" "git" "jq" "curl" "wget" "tmux")
CHEZMOI_INSTALL_DIR="$HOME/.local/bin"

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
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$CHEZMOI_INSTALL_DIR"
    echo "chezmoi installed to $CHEZMOI_INSTALL_DIR"
else
    echo "chezmoi is already installed."
fi

# --- 4. Success Message and Next Steps ---

echo "----------------------------------------------------"
echo "✅ Essential toolchain is installed."
echo "Your next step is to configure your shell and dotfiles."
echo "----------------------------------------------------"

# --- 4. Set Zsh as the Default Shell ---

if command -v zsh &> /dev/null; then
    ZSH_PATH=$(which zsh)
    CURRENT_SHELL="$SHELL"
    TARGET_USER=$(whoami)

    if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
        echo "Attempting to change default shell for user $TARGET_USER to $ZSH_PATH..."

        # The 'chsh' command requires root privileges (or sudo) and often prompts for a password.
        # Since this script is likely run with 'sudo' already, we use the SUDO_CMD.
        if command -v chsh &> /dev/null; then
            if [ -n "$SUDO_CMD" ]; then
                # Requires the user's password if the sudo timeout has expired.
                $SUDO_CMD chsh -s "$ZSH_PATH" "$TARGET_USER"

                if [ $? -eq 0 ]; then
                    echo "✅ Default shell successfully set for $TARGET_USER."
                    echo "NOTE: You must 'exit' your current session and start a new one (or log in again) to use Zsh."
                else
                    echo "⚠️ WARNING: Failed to change default shell via chsh. Password may be required."
                fi
            else
                echo "⚠️ WARNING: Cannot change default shell. 'chsh' requires root privileges or 'sudo'."
            fi
        fi
    else
        echo "Default shell is already set to Zsh."
    fi
fi

install_oh_my_zsh_minimal() {
    echo -e "## ${YELLOW}2. Installing Oh My Zsh (Pre-Config)...${RESET}"
    
    # Install Oh My Zsh if not present
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh structure..."
        # Install without prompting to change shell, suppress output
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &> /dev/null
        status "Oh My Zsh structure installed."
    else
        echo "Oh My Zsh is already installed."
    fi
    
    # Clone Zsh plugins (always necessary since OMZ doesn't manage these repos)
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    for repo_url in "${OH_MY_ZSH_PLUGINS_TO_CLONE[@]}"; do
        plugin_name=$(basename "$repo_url" .git)
        plugin_dir="${ZSH_CUSTOM}/plugins/$plugin_name"
        if [ ! -d "$plugin_dir" ]; then
            echo "Cloning $plugin_name..."
            run_command "git clone $repo_url $plugin_dir"
            status "Cloned $plugin_name."
        else
            echo "$plugin_name already exists. Skipping clone."
        fi
    done
}

OH_MY_ZSH_PLUGINS_TO_CLONE=(
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "https://github.com/zsh-users/zsh-autosuggestions.git"
    "https://github.com/fdellwing/zsh-bat.git"
)

install_oh_my_zsh_minimal
