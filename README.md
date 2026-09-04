![Verify Dotfiles](https://github.com/geonaut/dotfiles/actions/workflows/cm_verify.yaml/badge.svg)

# Geonaut's dotfiles

My personal dotfiles, installed via chezmoi.

## One-liners

### macOS

Homebrew first — it brings the Xcode Command Line Tools, without which `chezmoi init`
can't clone (`/usr/bin/git` is only a stub on a fresh Mac).

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
mkdir -p "$HOME/.local/bin" && sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply geonaut
```

### Ubuntu / Debian

```bash
sudo apt update && sudo apt install -y curl && sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply geonaut
```

## Testing on Ubuntu via Docker

```bash
# Local repo (default) — mounts and applies your working copy
./test/run.sh

# Remote — fetches and applies from GitHub
./test/run.sh --remote
```
