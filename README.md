![Verify Dotfiles](https://github.com/geonaut/dotfiles/actions/workflows/cm_verify.yaml/badge.svg)

# Geonaut's dotfiles

My personal dotfiles, installed via chezmoi.

## One-liners

```bash
mkdir -p "$HOME/.local/bin" && sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply geonaut
```

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
