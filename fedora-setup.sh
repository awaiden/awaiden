#!/bin/bash

echo "🚀 Starting Fedora Setup Script..."

# 1. System Update & Essential Packages
echo "📦 Updating system and installing base packages..."
sudo dnf update -y
sudo dnf install -y zsh git fastfetch gnome-tweaks gnome-shell-extension-manager xorg-x11-drv-nvidia-cuda curl wget

# 2. Add VS Code Repository & Install
echo "💻 Setting up Visual Studio Code repository..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
sudo dnf install -y code

# 3. Flathub Repository & Chrome Installation
echo "🛍️ Adding Flathub repository and installing Google Chrome..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.google.Chrome -y

# 4. Git Configuration
echo "🔧 Configuring Git..."
git config --global user.name "Halil Aydın"
git config --global user.email "aydinhalil980@gmail.com"
git config --global init.defaultBranch main

# 5. Generate SSH Key (if not exists)
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "🔑 Generating ED25519 SSH Key..."
    ssh-keygen -t ed25519 -C "aydinhalil980@gmail.com" -f ~/.ssh/id_ed25519 -N ""
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
fi

# 6. Development Tools (Zed, Bun, NVM, Node, pnpm)
echo "⚡ Installing Zed Editor..."
curl -f https://zed.dev/install.sh | sh

echo "🍞 Installing Bun..."
curl -fsSL https://bun.sh/install | bash

echo "🟢 Installing NVM & Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 24

echo "📦 Enabling pnpm via Corepack..."
corepack enable pnpm

# 7. Zsh, Oh My Zsh, Powerlevel10k & Plugins Setup
echo "🐚 Setting up Zsh, Oh My Zsh, Powerlevel10k and Plugins..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install Powerlevel10k
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# Install Plugins
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Write .zshrc configuration
cat << 'EOF' > ~/.zshrc
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# NVM Environment
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Bun Environment
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# Set Zsh as default shell
sudo chsh -s $(which zsh) $USER

echo "✅ SETUP COMPLETE! Please log out or restart your system for shell changes to take effect."
