# dotfiles

My personal dotfiles, installed via chezmoi

# Read-write access (MacOS)

* Make sure you have ssh access to Github
* Pull down the repo into `~/.local/share/chezmoi`: `chezmoi init https://github.com/geonaut/dotfiles.git`
* Run the bootstrap script `chmod +x .local/share/chezmoi/toolchains/macos/bootstrap.sh` then `.local/share/chezmoi/toolchains/macos/bootstrap.sh`
* `chezmoi apply && source ~/.zshrc`
* Tip: to run the brew / tmux install scripts each time, rename them to e.g. `run_after_install...` i.e. remove the `once`

# Installing the Linux Toolchain via read-only PAT

* Run `curl -fsSL -u "geonaut:<PAT>" https://raw.githubusercontent.com/geonaut/dotfiles/refs/heads/main/toolchains/ubuntu/bootstrap.sh| bash`
* Exec into zsh `exec zsh`

# Using chezmoi on an ephemeral machine

* Fetch & apply the chezmoi files `chezmoi init --apply https://geonaut:<PAT>@github.com/geonaut/dotfiles.git`

# Testing on Ubuntu via Docker

* Create a long-running container `docker run -d --name zsh_test ubuntu:latest /bin/bash -c "while true; do sleep 3600; done"`
* Exec into it `docker exec -it zsh_test /bin/login -f root`
* Install curl as a minimum. wget would also work `apt update && apt install -y curl`
* Run the bootstrap script, installing as root `curl -fsSL -u "geonaut:<PAT>" https://raw.githubusercontent.com/geonaut/dotfiles/refs/heads/main/toolchains/ubuntu/bootstrap.sh| bash`
* Switch to a non-root user e.g. `su ubuntu`
* Exec into zsh `exec zsh`
* Fetch & apply the chezmoi files `chezmoi init --apply https://geonaut:<PAT>@github.com/geonaut/dotfiles.git`
* Stop image `docker rm zsh_test`
* Delete image `docker stop zsh_test`
