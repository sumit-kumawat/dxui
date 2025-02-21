#!/bin/bash
set -e

# Dashboard Setup Script
# This script automates the setup and configuration of the Defendx Dashboard.

echo "Updating system packages..."
sudo yum update -y

echo "Disabling IPv6..."
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1

echo "Setting hostname to 'defendx'..."
sudo hostnamectl set-hostname defendx

echo "Configuring Dashboard permissions..."
sudo chown -R wazuh-user:wazuh-user /usr/share/wazuh-dashboard
sudo chmod -R 775 /usr/share/wazuh-dashboard

echo "Allowing binding to privileged ports..."
sudo setcap 'cap_net_bind_service=+ep' /usr/share/wazuh-dashboard/bin/opensearch-dashboards
sudo setcap 'cap_net_bind_service=+ep' /usr/share/wazuh-dashboard/node/fallback/bin/node

echo "Managing custom logo for Dashboard..."
sudo mkdir -p /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images
sudo chown -R wazuh:wazuh /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images
sudo chmod -R 755 /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images

echo "Ensuring correct ownership and permissions for configuration files..."
sudo chown wazuh-dashboard:wazuh-dashboard /usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml
sudo chmod 644 /usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml

echo "Restarting services..."
sudo systemctl restart wazuh-manager
sudo systemctl restart wazuh-dashboard

echo "Verifying services status..."
sudo systemctl status wazuh-manager
sudo systemctl status wazuh-dashboard

echo "Setup complete!"
