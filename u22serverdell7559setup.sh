#!/bin/bash

# Dell Inspiron 7559 Ubuntu Server Setup Script
# =============================================
# This script configures an Ubuntu server for optimal performance and readiness for
# further management by Puppet. It includes system optimizations, power settings,
# firewall configuration, and other adjustments tailored for a server use case.

# Ensure the script runs as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

echo "Starting Dell Inspiron 7559 Ubuntu server setup..."

# Update and upgrade the system
echo "Updating and upgrading system packages..."
apt update && apt upgrade -y

# Configure power settings: disable suspend on lid close
echo "Configuring power settings to prevent suspension on lid close..."
mkdir -p /etc/systemd/logind.conf.d
cat <<EOF > /etc/systemd/logind.conf.d/lid.conf
[Login]
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
EOF
systemctl restart systemd-logind

# Disable automatic updates (to prevent conflicts with Puppet-managed updates)
echo "Disabling automatic updates..."
systemctl stop apt-daily.timer
systemctl disable apt-daily.timer
systemctl stop apt-daily-upgrade.timer
systemctl disable apt-daily-upgrade.timer

# Configure timezone to Denver
echo "Configuring timezone to Denver (America/Denver)..."
timedatectl set-timezone "America/Denver"

# Configure UFW (Uncomplicated Firewall) rules
echo "Setting up UFW firewall rules..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 8140/tcp  # Puppet Server
ufw --force enable  # Enable UFW without prompting for confirmation

# Optimize swappiness
echo "Optimizing swappiness for performance..."
sysctl vm.swappiness=10
echo "vm.swappiness=10" >> /etc/sysctl.conf
sysctl -p

# Set up a swap file
echo "Setting up a swap file..."
fallocate -l 4G /swapfile  # Adjust size if needed
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Enable SSD optimizations
echo "Enabling SSD optimizations..."
echo 'mq-deadline' > /sys/block/sdX/queue/scheduler  # Replace sdX with your SSD device
systemctl enable fstrim.timer

# Performance tuning for networking
echo "Applying performance tuning for networking..."
cat <<EOF >> /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 5000
net.core.somaxconn = 1024
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
EOF
sysctl -p

# Clean up unused packages
echo "Cleaning up unused packages..."
apt autoremove -y && apt autoclean -y

# Print completion message
echo "Dell Inspiron 7559 Ubuntu server setup complete! Please reboot for all changes to take effect."
