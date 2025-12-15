# dotfiles

My personal dotfiles, installed via chezmoi

# Installing the Linux Toolchain

* Run `curl -fsSL -u "geonaut:<PAT>" https://raw.githubusercontent.com/geonaut/dotfiles/refs/heads/main/toolchains/ubuntu/bootstrap.sh| bash`
* Exec into zsh `exec zsh`

# Using chezmoi

* Fetch & apply the chezmoi files `chezmoi init --apply https://geonaut:<PAT>@github.com/geonaut/dotfiles.git`

# Testing

* Create a long-running container `docker run -d --name zsh_test ubuntu:latest /bin/bash -c "while true; do sleep 3600; done"`
* Exec into it `docker exec -it zsh_test /bin/login -f root`
* Install curl as a minimum. wget would also work `apt update && apt install -y curl`
* Run the bootstrap script, installing as root `curl -fsSL -u "geonaut:<PAT>" https://raw.githubusercontent.com/geonaut/dotfiles/refs/heads/main/toolchains/ubuntu/bootstrap.sh| bash`
* Switch to a non-root user e.g. `su ubuntu`
* Exec into zsh `exec zsh`
* Fetch & apply the chezmoi files `chezmoi init --apply https://geonaut:<PAT>@github.com/geonaut/dotfiles.git`
* Stop image `docker rm zsh_test`
* Delete image `docker stop zsh_test`
