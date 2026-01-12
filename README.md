# Geonaut's dotfiles

My personal dotfiles, installed via chezmoi.

## 

`sudo apt update && sudo apt install -y curl && sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply geonaut`

## Testing on Ubuntu Server via Docker

* Create a long-running container `docker run -d --name zsh_test ubuntu:latest /bin/bash -c "while true; do sleep 3600; done"`
* Exec into it `docker exec -it zsh_test /bin/login -f root`
* One-liner
* Stop image `docker rm zsh_test`
* Delete image `docker stop zsh_test`
