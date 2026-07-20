#!/bin/bash

echo "🚀 Starting Fedora Setup Script..."

# 1. System Update & Essential Packages
echo "📦 Updating system and installing base packages..."
sudo dnf update -y
sudo dnf install -y zsh git fastfetch gnome-tweaks gnome-shell-extension-manager auto-cpufreq bleachbit xorg-x11-drv-nvidia-cuda

# 2. Add VS Code Repository & Install
echo "💻 Setting up Visual Studio Code repository..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
sudo dnf install -y code

# 3. Flathub Repository
echo "🛍️ Adding Flathub repository..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

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

# 6. Auto-Clean Systemd Services
echo "🧹 Configuring automated system cleanup service..."
sudo bash -c 'cat <<EOF > /etc/systemd/system/auto-clean.service
[Unit]
Description=Advanced Weekly System and Cache Cleanup

[Service]
Type=oneshot
ExecStart=/usr/bin/dnf clean all
ExecStart=/usr/bin/journalctl --vacuum-size=100M
ExecStart=/usr/bin/bleachbit --clean system.cache system.tmp deepscan.tmp
EOF'

sudo bash -c 'cat <<EOF > /etc/systemd/system/auto-clean.timer
[Unit]
Description=Weekly Cleanup Timer

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable --now auto-clean.timer
sudo auto-cpufreq --install

echo "✅ SETUP COMPLETE! A system reboot is recommended."
