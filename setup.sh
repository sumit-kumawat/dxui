#!/bin/bash
set -e

# Update System Packages
sudo yum update -y

# Disable IPv6
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# Set Hostname
sudo hostnamectl set-hostname defendx

# Configure Wazuh Dashboard Permissions
sudo chown -R wazuh-user:wazuh-user /usr/share/wazuh-dashboard
sudo chmod -R 775 /usr/share/wazuh-dashboard

# Allow Binding to Privileged Ports
sudo setcap 'cap_net_bind_service=+ep' /usr/share/wazuh-dashboard/bin/opensearch-dashboards
sudo setcap 'cap_net_bind_service=+ep' /usr/share/wazuh-dashboard/node/fallback/bin/node

# Manage Custom Logo for Wazuh Dashboard
sudo mkdir -p /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images
sudo chown -R wazuh:wazuh /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images
sudo chmod -R 755 /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images

# Ensure Configuration File Ownership & Permissions
sudo chown wazuh-dashboard:wazuh-dashboard /usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml
sudo chmod 644 /usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml
