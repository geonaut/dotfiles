![Verify Dotfiles](https://github.com/geonaut/dotfiles/actions/workflows/cm_verify.yaml/badge.svg)

# Geonaut's dotfiles

My personal dotfiles, installed via chezmoi.

## One-liners

### macOS

Homebrew **must** go first — its installer pulls in the Xcode Command Line Tools:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
mkdir -p "$HOME/.local/bin" && sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply geonaut
```

On a fresh macOS install `/usr/bin/git` is only a stub that fails with
`xcrun: error: invalid active developer path`. `chezmoi init` shells out to it to
clone this repo and dies before any script here can run, so the toolchain has to
exist beforehand. (`useBuiltinGit` defaults to `auto`, which only falls back to
chezmoi's builtin git when git is *missing* from `$PATH` — the stub is present,
so the fallback never triggers.)

If the Command Line Tools are already installed, the Homebrew line is a no-op and
you can skip straight to the `chezmoi` line.

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
