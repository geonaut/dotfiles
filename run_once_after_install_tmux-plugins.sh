#!/bin/bash

# Chezmoi runs this script after the .tmux.conf file has been linked.

TMUX_PLUGINS_DIR="$HOME/.tmux/plugins"
TPM_REPO="https://github.com/tmux-plugins/tpm"

echo "Checking for Tmux Plugin Manager (TPM)..."

# 1. Check if TPM is already cloned
if [ ! -d "$TMUX_PLUGINS_DIR/tpm" ]; then
    echo "TPM not found. Cloning repository..."
    
    # Run git clone silently
    if command -v git >/dev/null 2>&1; then
        git clone "$TPM_REPO" "$TMUX_PLUGINS_DIR/tpm" &> /dev/null
        echo "TPM cloned successfully."
    else
        echo "Error: Git is required to clone TPM, but was not found."
        exit 1
    fi
else
    echo "TPM repository already exists."
fi

# 2. Run the installation/update command
# This command sources your new .tmux.conf and runs the plugin installation from within Tmux.
# We use the system-level tmux binary path if available.
if command -v tmux >/dev/null 2>&1; then
    echo "Installing/Updating Tmux Plugins..."
    
    # Send the "Install" command (Prefix + I) to any active tmux server.
    # This command uses 'tmux source' to load the config, which triggers the 'run' command at the end.
    tmux start-server # Ensure server is running for source-file command
    tmux source-file "$HOME/.tmux.conf"

    # If you want to automatically install all plugins without manual intervention, 
    # you can send the prefix + I keystroke. However, running `source-file` is often sufficient
    # to trigger the install if the plugins directory is empty.
    
    echo "Tmux plugins installation triggered. Start tmux to finalize, or run (Prefix + I)."
fi