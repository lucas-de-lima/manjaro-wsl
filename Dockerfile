FROM manjarolinux/base:latest

LABEL maintainer="Lucas <your-email@example.com>"
LABEL description="Manjaro RootFS Generator for WSL2"

# 1. Basic Setup and Packages
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git vim zsh sudo wget fastfetch && \
    pacman -Sc --noconfirm

# 2. User Configuration
RUN useradd -m -G wheel -s /bin/zsh manjaro && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

# 3. ZSH Configuration
# We create a simple .zshrc for the manjaro user
USER manjaro
RUN echo 'autoload -Uz compinit promptinit' > ~/.zshrc && \
    echo 'compinit' >> ~/.zshrc && \
    echo 'promptinit' >> ~/.zshrc && \
    echo 'prompt walters' >> ~/.zshrc && \
    echo 'alias ll="ls -la"' >> ~/.zshrc && \
    echo 'echo "☕ Welcome to Manjaro WSL. Type fastfetch to see the specs."' >> ~/.zshrc

# Switch back to root to copy system configurations if needed
USER root

# 4. Inject WSL configuration
COPY config/wsl.conf /etc/wsl.conf

# 5. Final Adjustments
USER manjaro
WORKDIR /home/manjaro

CMD ["/bin/zsh"]