#!/bin/bash

# Ensure the script runs as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Variables
FQDN="rtj.puppet.com"
SHORTNAME="rtj"
IP_ADDRESS="127.0.0.1"  # Replace with the server's static IP if applicable

echo "Setting FQDN to $FQDN..."

# Set the hostname
echo "Updating hostname..."
hostnamectl set-hostname "$FQDN"

# Update /etc/hosts
echo "Updating /etc/hosts..."
if grep -q "$FQDN" /etc/hosts; then
    echo "FQDN already exists in /etc/hosts. Updating..."
    sed -i "s/.*$FQDN.*/$IP_ADDRESS   $FQDN $SHORTNAME/" /etc/hosts
else
    echo "$IP_ADDRESS   $FQDN $SHORTNAME" >> /etc/hosts
fi

# Update /etc/hostname
echo "Updating /etc/hostname..."
echo "$SHORTNAME" > /etc/hostname

# Restart networking to apply changes
echo "Restarting networking services..."
systemctl restart networking

# Verify changes
echo "Verifying configuration..."
echo "Hostname: $(hostname)"
echo "FQDN: $(hostname --fqdn)"

echo "FQDN setup complete. Please ensure DNS records for $FQDN are properly configured if needed."
