FROM manjarolinux/base:latest

LABEL maintainer="Lucas"
LABEL description="Manjaro RootFS Generator for WSL2"

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git vim zsh sudo wget fastfetch unzip && \
    pacman -Sc --noconfirm

RUN useradd -m -G wheel -s /bin/zsh manjaro && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

USER manjaro
RUN echo 'autoload -Uz compinit promptinit' > ~/.zshrc && \
    echo 'compinit' >> ~/.zshrc && \
    echo 'promptinit' >> ~/.zshrc && \
    echo 'prompt walters' >> ~/.zshrc && \
    echo 'alias ll="ls -la"' >> ~/.zshrc

USER root

COPY config/wsl.conf /etc/wsl.conf

COPY config/wsl-distribution.conf /etc/wsl-distribution.conf

RUN mkdir -p /usr/lib/wsl
COPY config/manjaro.ico /usr/lib/wsl/manjaro.ico
# --------------------------------------------------

USER manjaro
WORKDIR /home/manjaro

CMD ["/bin/zsh"]