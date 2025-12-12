# Manjaro WSL Post-Installation Guide

A guide to transform your Manjaro WSL into a robust development environment. Follow the steps in order.

## 1\. Basic Setup

**Before starting:** `sudo pacman -Syyu`

## 2\. Optimize Mirrors

Speed up package downloads:

```bash
sudo pacman-mirrors --fasttrack 5
sudo pacman -Syyu
```

## 3\. AUR Setup (Yay)

Install yay to access the Arch User Repository:

```bash
# Install build dependencies
sudo pacman -S --needed base-devel git

# Clone yay
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay

# Compile and install
makepkg -si
```

**Note:** Press Enter when prompted with "Diffs to show?"

## 4\. Version Manager (ASDF)

Install ASDF via AUR:

```bash
# Install via yay
yay -S asdf-vm

# Add to .zshrc
echo 'export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"' >> ~/.zshrc

# Reload
source ~/.zshrc
```

## 5\. Terminal Theme (Powerlevel10k)

### Step A: Install Font on Windows

1.  Download [MesloLGS NF font](https://github.com/romkatv/dotfiles-public?tab=readme-ov-file#windows-preparation)
2.  Install by double-clicking
3.  Restart Windows Terminal and configure the font in Manjaro profile settings

### Step B: Install Theme on Linux

```bash
# Install theme
yay -S zsh-theme-powerlevel10k-git

# Add to .zshrc
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc
```

### Step C: Configure Theme

Close and reopen the terminal. The Powerlevel10k wizard will start automatically.

## 6\. ZSH Plugins (Autocomplete & Highlighting)

Install lightweight plugins manually to enable command suggestions (grey text) and syntax highlighting (colors for valid/invalid commands).

```bash
# Create plugins directory
mkdir -p ~/.zsh

# 1. Install Autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
echo "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc

# 2. Install Syntax Highlighting (Must be loaded last)
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
echo "source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc

# Apply changes
source ~/.zshrc
```

## 7\. Modern Tools

Install modern replacements for traditional commands:

```bash
# Install tools
yay -S bat eza fd ripgrep

# Add aliases to .zshrc
cat >> ~/.zshrc <<EOF

# Modern aliases
alias cat='bat'
alias ls='eza --icons'
alias find='fd'
alias grep='rg'
EOF
```

## 8\. Docker Integration

Use Docker from Windows within Manjaro:

1.  Open Docker Desktop on Windows
2.  Go to Settings → Resources → WSL Integration
3.  Enable Manjaro
4.  Restart Manjaro terminal
5.  Test: `docker ps`
