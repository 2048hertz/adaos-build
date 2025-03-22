#!/bin/bash

set -e  # Exit script on error

echo "Setting up Rocky Linux Workstation with Complete Optimizations..."

# Update system & enable necessary repositories
echo "Updating system and enabling repositories..."
sudo dnf update -y
sudo dnf install -y epel-release
sudo dnf config-manager --set-enabled crb  # Enable PowerTools

# Install core system utilities
echo "🛠 Installing core utilities..."
sudo dnf install -y nano vim wget curl git unzip tar xz htop neofetch \
    bash-completion lsof tmux net-tools tree rsync screen bc jq

# Install workstation essentials
echo "Installing workstation essential tools..."
sudo dnf install -y libreoffice flatpak \
    fonts-roboto google-noto-emoji-fonts \
    gnome-themes-extra papirus-icon-theme arc-theme \
    vlc gimp krita blender inkscape audacity \
    xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-utils xorg-x11-xinit

# Remove Rocky Linux customizations from Firefox
echo "Removing Rocky Linux customizations from Firefox..."
sudo dnf remove -y rocky-release-rocky-browser
sudo dnf install -y firefox
rm -rf ~/.mozilla/firefox ~/.config/mozilla
echo "user_pref(\"distribution.id\", \"\");" > ~/.mozilla/firefox/default-release/user.js

# Install graphics drivers (AMD, NVIDIA, Intel)
echo "Installing graphics drivers..."
sudo dnf install -y mesa-dri-drivers mesa-libGLU xorg-x11-drv-amdgpu xorg-x11-drv-intel
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda vulkan-tools

# Install performance and I/O optimization tools
echo "Optimizing system performance..."
sudo dnf install -y tuned tuned-utils iotop powertop irqbalance cpupower numactl

# Apply tuned profile for workstations
sudo tuned-adm profile latency-performance
sudo systemctl enable --now tuned

# Enable CPU power optimizations
echo "GOVERNOR=performance" | sudo tee /etc/default/cpupower
sudo systemctl enable --now cpupower

# Install development tools
echo "Installing development tools..."
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y gcc gcc-c++ make cmake automake autoconf \
    kernel-devel kernel-headers ninja-build pkg-config gettext \
    python3 python3-pip python3-devel \
    nodejs npm \
    rust cargo \
    golang java-11-openjdk java-17-openjdk

# Install virtualization tools
echo "Installing virtualization tools..."
sudo dnf install -y qemu-kvm libvirt virt-manager virt-install \
    bridge-utils dnsmasq vagrant podman podman-compose

sudo systemctl enable --now libvirtd

# Install Docker & Kubernetes
echo "Installing Docker & Kubernetes..."
sudo dnf install -y docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

sudo dnf install -y kubectl helm minikube

# Install security tools
echo "🛡 Installing security tools..."
sudo dnf install -y policycoreutils-python-utils selinux-policy-targeted \
    fail2ban clamav clamav-update ufw firewalld rkhunter chkrootkit 

sudo systemctl enable --now firewalld fail2ban
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# Optimize SSH for security
echo "Hardening SSH..."
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
echo "MaxAuthTries 3" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd

# Enable Flatpak and install common apps
echo "Installing Flatpak apps..."
sudo dnf install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.visualstudio.code org.videolan.VLC

# Cleaning up
echo "Cleaning up unnecessary files..."
sudo dnf clean all
sudo updatedb  # Update the locate database

echo "Workstation setup complete!"
echo "Reboot your system to apply changes."

   
