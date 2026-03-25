FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN apt-get update && apt-get install -y curl git sudo

# Create a non-root user to mimic a real setup
RUN useradd -m -s /bin/bash testuser && echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# Pre-seed chezmoi config to avoid interactive prompts
RUN mkdir -p "$HOME/.config/chezmoi" && cat > "$HOME/.config/chezmoi/chezmoi.toml" <<'EOF'
[data]
    install_languages = false
    is_server = true
    using_bazel = false
    using_k8s = true
    using_tf = false
    will_edit_cm = false
EOF

# Install chezmoi only (apply happens at container start via entrypoint)
RUN mkdir -p "$HOME/.local/bin" && \
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"

COPY --chown=testuser:testuser entrypoint.sh /home/testuser/entrypoint.sh

ENTRYPOINT ["/home/testuser/entrypoint.sh"]
CMD ["/bin/zsh", "-l"]
