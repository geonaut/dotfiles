#!/bin/bash

set -e

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

PKG_MANAGER="apt-get"
INSTALL_CMD="$SUDO_CMD $PKG_MANAGER install -y"
UPDATE_CMD="$SUDO_CMD $PKG_MANAGER update"
sudo apt-get update

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

if command -v zsh &> /dev/null; then
    ZSH_PATH=$(which zsh)
    CURRENT_SHELL="$SHELL"
    TARGET_USER=$(whoami)

    if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
        echo "Attempting to change default shell for user $TARGET_USER to $ZSH_PATH..."

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
            git clone $repo_url $plugin_dir
            status "Cloned $plugin_name."
        else
            echo "$plugin_name already exists. Skipping clone."
        fi
    done
}

install_oh_my_zsh_minimal

install_powerlevel10k_theme() {
    echo -e "## ${YELLOW}Installing Powerlevel10k Theme...${RESET}"
    local P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    local P10K_REPO="https://github.com/romkatv/powerlevel10k.git"

    if [ ! -d "$P10K_DIR" ]; then
        echo "Cloning Powerlevel10k into themes directory..."
        # Clones directly into the themes directory where OMZ expects it
        run_command "git clone --depth=1 $P10K_REPO $P10K_DIR"
        status "Powerlevel10k cloned."
    else
        echo "Powerlevel10k theme already exists. Skipping clone."
    fi
}

install_powerlevel10k_theme

USER_NAME=$(whoami)

echo "Changing default shell for user $USER_NAME to Zsh..."

# Use chsh (change shell) command to set Zsh as the default
# The -s flag specifies the path to the new shell
chsh -s "$(which zsh)" "$USER_NAME"

# Check the exit status of the chsh command
if [ $? -eq 0 ]; then
    echo "Successfully changed default shell to Zsh for $USER_NAME."
    echo "---------------------------------------------------------"
    echo "ACTION REQUIRED: Please log out and log back in (or reboot) to start using Zsh."
    echo "---------------------------------------------------------"
else
    echo "ERROR: Failed to change default shell. Please check your password and try manually:"
    echo "chsh -s \$(which zsh)"
fi
