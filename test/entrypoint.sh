#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

CHEZMOI="$HOME/.local/bin/chezmoi"
LOCAL_SOURCE="/dotfiles"

if [ -d "$LOCAL_SOURCE" ]; then
    echo "=> Applying dotfiles from local source..."
    "$CHEZMOI" init --apply --source="$LOCAL_SOURCE"
else
    echo "=> Applying dotfiles from GitHub..."
    "$CHEZMOI" init --apply geonaut
fi

exec "$@"
