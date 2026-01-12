#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

REQUIRED_CLI_TOOLS=("zsh" "git" "jq" "curl" "wget" "tmux")
CHEZMOI_INSTALL_DIR="$HOME/.local/bin"
OH_MY_ZSH_PLUGINS_TO_CLONE=(
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "https://github.com/zsh-users/zsh-autosuggestions.git"
    "https://github.com/fdellwing/zsh-bat.git"
)

run_command() {
    local cmd="$@"
    eval "$cmd" &> /dev/null
}

status() {
    echo -e "${GREEN}✅ $1${RESET}"
}

warn() {
    echo -e "${YELLOW}⚠️ $1${RESET}"
}

error() {
    echo -e "${RED}🛑 $1${RESET}"
}

SUDO_CMD=""
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo &> /dev/null; then
        SUDO_CMD="sudo"
    else
        echo "Error: This script requires root or sudo."
        exit 1
    fi
fi

PKG_MANAGER="apt-get"
INSTALL_CMD="$SUDO_CMD $PKG_MANAGER install -y"
UPDATE_CMD="$SUDO_CMD $PKG_MANAGER update"
sudo apt-get update

change_shell() {
    local target_zsh
    target_zsh=$(command -v zsh)
    local user_name
    user_name=$(whoami)

    echo "Checking shell configuration for $user_name..."

    # Check if user is in /etc/passwd (Local User)
    if ! grep -q "^${user_name}:" /etc/passwd; then
        warn "User '$user_name' not found in /etc/passwd. Skipping 'chsh' as shell is likely managed externally (LDAP/SSO)."
        return 0
    fi

    if [ "$SHELL" = "$target_zsh" ]; then
        status "Shell is already Zsh."
        return 0
    fi

    echo "Attempting to change default shell to Zsh..."
    # We use '|| true' or a manual check to prevent 'set -e' from killing the script if chsh fails
    if $SUDO_CMD chsh -s "$target_zsh" "$user_name"; then
        status "Successfully changed default shell to Zsh."
    else
        warn "Failed to change shell with chsh. Since you manage this externally, please ensure your provider is set to Zsh."
    fi
}

change_shell || true

for tool in "${REQUIRED_CLI_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Installing $tool..."
        sudo apt-get install -y "$tool"
    else
        echo "$tool is already installed."
    fi
done

if ! command -v chezmoi &> /dev/null; then
    echo "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$CHEZMOI_INSTALL_DIR"
    echo "chezmoi installed to $CHEZMOI_INSTALL_DIR"
else
    echo "chezmoi is already installed."
fi

echo "----------------------------------------------------"
echo "✅ Essential toolchain is installed."
echo "Your next step is to configure your shell and dotfiles."
echo "----------------------------------------------------"

# if command -v zsh &> /dev/null; then
#     ZSH_PATH=$(which zsh)
#     CURRENT_SHELL="$SHELL"
#     TARGET_USER=$(whoami)

#     if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
#         echo "Attempting to change default shell for user $TARGET_USER to $ZSH_PATH..."

#         if command -v chsh &> /dev/null; then
#             if [ -n "$SUDO_CMD" ]; then
#                 # Requires the user's password if the sudo timeout has expired.
#                 $SUDO_CMD chsh -s "$ZSH_PATH" "$TARGET_USER"

#                 if [ $? -eq 0 ]; then
#                     echo "✅ Default shell successfully set for $TARGET_USER."
#                     echo "NOTE: You must 'exit' your current session and start a new one (or log in again) to use Zsh."
#                 else
#                     echo "⚠️ WARNING: Failed to change default shell via chsh. Password may be required."
#                 fi
#             else
#                 echo "⚠️ WARNING: Cannot change default shell. 'chsh' requires root privileges or 'sudo'."
#             fi
#         fi
#     else
#         echo "Default shell is already set to Zsh."
#     fi
# fi

install_oh_my_zsh_minimal() {
    echo -e "## ${YELLOW}Installing Oh My Zsh (Pre-Config)...${RESET}"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        # Use --unattended to prevent it from trying to switch shell itself
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    for repo_url in "${OH_MY_ZSH_PLUGINS_TO_CLONE[@]}"; do
        plugin_name=$(basename "$repo_url" .git)
        plugin_dir="${ZSH_CUSTOM}/plugins/$plugin_name"
        if [ ! -d "$plugin_dir" ]; then
            git clone "$repo_url" "$plugin_dir"
        fi
    done
}

install_oh_my_zsh_minimal

install_nerd_fonts() {
    local FONT_DIR="$HOME/.local/share/fonts"
    if [ -d "$FONT_DIR/Hack" ]; then
        echo "✅ Hack Nerd Font already installed."
        return
    fi

    echo "📦 Installing Hack Nerd Font for Desktop..."
    mkdir -p "$FONT_DIR/Hack"

    # Download specifically the Hack Nerd Font files
    # We use 'unzip' which you should add to your REQUIRED_CLI_TOOLS
    curl -fLo "/tmp/Hack.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"
    unzip -o "/tmp/Hack.zip" -d "$FONT_DIR/Hack"
    rm "/tmp/Hack.zip"

    # Update font cache so the system sees them
    if command -v fc-cache &> /dev/null; then
        fc-cache -f "$FONT_DIR"
    fi
}

install_nerd_fonts

install_starship() {
    echo -e "## ${YELLOW}Installing Starship...${RESET}"
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
    fi
}

install_starship

# Only add to .bashrc if it's not already there
if ! grep -q '.local/bin' ~/.bashrc; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
  echo "Added ~/.local/bin to PATH in .bashrc"
fi

# Apply it to the current session immediately
export PATH="$HOME/.local/bin:$PATH"
