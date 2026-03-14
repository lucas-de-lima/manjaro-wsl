# Manjaro WSL Post-Installation Guide

A guide to transform your Manjaro WSL into a robust development environment. Follow the steps in order.

## 1. Basic Setup and Mirror Optimization

Optimize mirrors first, then update the system:

```bash
sudo pacman-mirrors --fasttrack 5
sudo pacman -Syyu
```

## 2. AUR Setup (Yay)

Install yay to access the Arch User Repository. Build dependencies (`base-devel`, `git`) are already installed in the rootfs.

```bash
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay

# Compile and install
makepkg -si
```

**Note:** Press Enter when prompted with "Diffs to show?"

## 3. Version Manager (ASDF)

Install ASDF via AUR:

```bash
# Install via yay
yay -S asdf-vm

# Add to .zshrc
echo 'export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"' >> ~/.zshrc

# Reload
source ~/.zshrc
```

## 4. Terminal Theme (Powerlevel10k)

### Step A: Install Font on Windows

1.  Download [MesloLGS NF font](https://github.com/romkatv/dotfiles-public?tab=readme-ov-file#windows-preparation)
2.  Install by double-clicking
3.  Restart Windows Terminal. In Windows Terminal: open **Settings** → select the **Manjaro** profile → go to the **Appearance** tab → in the **Font** field, select **MesloLGS NF**

### Step B: Install Theme on Linux

```bash
# Install theme
yay -S zsh-theme-powerlevel10k-git

# Add to .zshrc
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc
```

### Step C: Configure Theme

**Before opening the Manjaro terminal again:** open **Windows Terminal Settings**, select the **Manjaro** distro profile, and set the **font** to **MesloLGS NF** (Appearance tab). Only then open the Manjaro terminal. If you skip this step, the Powerlevel10k wizard will show unrecognized characters as "?" during setup.

Then close and reopen the terminal. The Powerlevel10k wizard will start automatically.

## 5. ZSH Plugins (Autocomplete & Highlighting)

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

## 6. Modern Tools

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

## 7. Docker Integration

Use Docker from Windows within Manjaro:

1.  Open Docker Desktop on Windows
2.  Go to Settings → Resources → WSL Integration
3.  Enable Manjaro
4.  Restart Manjaro terminal
5.  Test: `docker ps`
