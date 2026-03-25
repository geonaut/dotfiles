#!/bin/bash
set -e

IMAGE_NAME="dotfiles-test"
CONTAINER_NAME="dotfiles-test"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

usage() {
    echo "Usage: $0 [--remote]"
    echo "  Default: mounts and applies local repo"
    echo "  --remote: fetches and applies from GitHub"
    exit 1
}

MODE="local"
if [ "${1:-}" = "--remote" ]; then
    MODE="remote"
elif [ -n "${1:-}" ]; then
    usage
fi

# Clean up any previous container
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Build the image
docker build --no-cache -t "$IMAGE_NAME" "$SCRIPT_DIR"

# Run interactively
if [ "$MODE" = "local" ]; then
    echo "=> Using local repo: $REPO_DIR"
    docker run -it --rm --name "$CONTAINER_NAME" \
        -v "$REPO_DIR:/dotfiles:ro" \
        "$IMAGE_NAME"
else
    echo "=> Using GitHub remote"
    docker run -it --rm --name "$CONTAINER_NAME" "$IMAGE_NAME"
fi
