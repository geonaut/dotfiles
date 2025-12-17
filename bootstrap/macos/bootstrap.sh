#!/bin/bash

# --- Color Codes ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m' # No Color

# --- Configuration Variables ---
CHEZMOI_REPO="https://github.com/geonaut/dotfiles.git" 
OH_MY_ZSH_PLUGINS_TO_CLONE=(
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "https://github.com/zsh-users/zsh-autosuggestions.git"
    "https://github.com/fdellwing/zsh-bat.git"
)

# -------------------------------------------------------------------
# VERBOSITY CODE REMOVED FOR CLEANLINESS AND SIMPLICITY
# -------------------------------------------------------------------

# Function to execute commands silently (default behavior)
run_command() {
    # All commands are executed silently unless the function uses 'echo'
    local cmd="$@"
    eval "$cmd" &> /dev/null
}

# Function for status messages
status() {
    echo -e "${GREEN}✅ $1${RESET}"
}

# Function for warning messages
warn() {
    echo -e "${YELLOW}⚠️ $1${RESET}"
}

# Function for error messages
error() {
    echo -e "${RED}🛑 $1${RESET}"
}


# --- Function Definitions ---

check_requirements() {
    if ! command -v git &> /dev/null; then
        error "Git is required but not installed. Cannot proceed."
        exit 1
    fi
}

# --- 1. Install Homebrew ---
install_homebrew() {
    echo -e "## ${YELLOW}1. Checking for Homebrew...${RESET}"
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        
        # Install Homebrew silently
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH immediately for use in this script
        if [[ "$(uname -m)" == "arm64" ]]; then
            export PATH="/opt/homebrew/bin:$PATH"
        else
            export PATH="/usr/local/bin:$PATH"
        fi

        status "Homebrew installed and added to PATH."
    else
        echo "Homebrew is already installed. Running update..."
        run_command "brew update"
        status "Homebrew update complete."
    fi
}

# --- 2. Minimal Install of Oh My Zsh (Zsh is installed later via Brewfile) ---
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

# --- 3. Minimal Install of Chezmoi ---
# This installs Chezmoi, initializes it, and applies the dotfiles (including the Brewfile).
install_chezmoi_minimal() {
    echo -e "## ${YELLOW}3. Installing Chezmoi (Minimal)...${RESET}"
    if ! command -v chezmoi &> /dev/null; then
        echo "Installing Chezmoi via script, initializing, and applying dotfiles..."
        
        # Install Chezmoi using its single-line install, which also runs init --apply
        # Output is silenced
        sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$HOME/.local/bin" init --apply "$CHEZMOI_REPO" &> /dev/null

        # Add Chezmoi's custom install path to PATH for immediate use
        export PATH="$HOME/.local/bin:$PATH"
        status "Chezmoi installed, initialized, and applied."
    else
        echo "Chezmoi is already installed. Skipping minimal install."
    fi
}

# install_powerlevel10k_theme() {
#     echo -e "## ${YELLOW}Installing Powerlevel10k Theme...${RESET}"
#     local P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
#     local P10K_REPO="https://github.com/romkatv/powerlevel10k.git"

#     if [ ! -d "$P10K_DIR" ]; then
#         echo "Cloning Powerlevel10k into themes directory..."
#         # Clones directly into the themes directory where OMZ expects it
#         run_command "git clone --depth=1 $P10K_REPO $P10K_DIR"
#         status "Powerlevel10k cloned."
#     else
#         echo "Powerlevel10k theme already exists. Skipping clone."
#     fi
# }
# Call this function after install_oh_my_zsh_minimal


# --- Main Execution ---

install_homebrew
check_requirements
install_oh_my_zsh_minimal
install_chezmoi_minimal 

# --- 4. Final Steps (Check and Set Login Shell) ---
echo -e "## ${YELLOW}4. Final Steps${RESET}"

ZSH_HB_PATH=$(which zsh)
SYSTEM_SHELL_PATH="/bin/zsh"
# Use 'dscl' to determine the actual login shell setting from the user database on macOS
CURRENT_LOGIN_SHELL=$(dscl . -read "/Users/$USER" UserShell | awk '{print $NF}')

if [ -n "$ZSH_HB_PATH" ] && [ "$ZSH_HB_PATH" != "$SYSTEM_SHELL_PATH" ]; then
    
    # 4a. Check if the Homebrew path is registered in /etc/shells
    if grep -q "$ZSH_HB_PATH" /etc/shells; then
        
        # 4b. Check if the login shell is already set to the Homebrew Zsh path
        if [ "$CURRENT_LOGIN_SHELL" != "$ZSH_HB_PATH" ]; then
            
            echo -e "${YELLOW}Attempting to set login shell to: $ZSH_HB_PATH...${RESET}"
            
            # Use 'chsh' which will prompt for a password
            if run_command "/usr/bin/chsh -s \"$ZSH_HB_PATH\""; then
                 status "Default login shell successfully set to Homebrew Zsh. You must log out and back in."
            else
                 # If chsh fails (due to missing password/sudo), print a clear error.
                 error "The attempt to set the default login shell non-interactively failed."
                 error "You must manually run the following command and enter your password:"
                 echo -e "${RED}    sudo chsh -s \"$ZSH_HB_PATH\" \"\$USER\"${RESET}"
            fi
        else
            status "Login shell is already set to the correct Homebrew Zsh path ($ZSH_HB_PATH). Skipping chsh."
        fi
        
    else
        # --- PATH IS NOT REGISTERED: Print the critical fix ---
        warn "The Homebrew Zsh path ($ZSH_HB_PATH) is NOT listed in /etc/shells."
        error "This prevents 'chsh' from being able to set it as your default login shell."
        
        echo -e "\n${YELLOW}🛠️ **REQUIRED MANUAL STEP**${RESET}"
        echo "1. **Register the Path:** Add the Homebrew Zsh path to the list of valid shells."
        echo "   (You will need to enter your password for this step)"
        echo -e "${RED}   echo \"$ZSH_HB_PATH\" | sudo tee -a /etc/shells${RESET}"
        
        echo "2. **Set the Shell:** Once registered, run the 'chsh' command manually."
        echo -e "${RED}   /usr/bin/chsh -s \"$ZSH_HB_PATH\"${RESET}"
        
        echo -e "\n${YELLOW}Note: After setting the shell, you must log out and back in for the change to take effect.${RESET}"
    fi
fi

echo -e "\n---"
echo -e "${GREEN}✅ Bootstrap complete! Your shell is ready.${RESET}"