# Wazuh Dashboard Setup & Configuration Guide

## Table of Contents
- [System Preparation](#system-preparation)
- [Setting Hostname](#setting-hostname)
- [Configuring Wazuh Dashboard Permissions](#configuring-wazuh-dashboard-permissions)
- [Managing Custom Logo for Wazuh Dashboard](#managing-custom-logo-for-wazuh-dashboard)
- [Configuring Wazuh Configuration File](#configuring-wazuh-configuration-file)
- [Restarting Wazuh Services](#restarting-wazuh-services)
- [Custom Branding (Title, Hostname, Boot, Banner)](#custom-branding-title-hostname-boot-banner)
- [Clearing Cache](#clearing-cache)
- [Troubleshooting Commands](#troubleshooting-commands)

---

## System Preparation
```bash
# Update system packages & disable IPv6 in one step
sudo yum update -y && sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 \
    && sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 \
    && sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
```

---

## Setting Hostname
```bash
sudo hostnamectl set-hostname defendx
```

---

## Configuring Wazuh Dashboard Permissions
```bash
# Set ownership & permissions for Wazuh Dashboard
sudo chown -R admin:admin /usr/share/wazuh-dashboard && sudo chmod -R 775 /usr/share/wazuh-dashboard
# Set capabilities for privileged port binding
sudo setcap 'cap_net_bind_service=+ep' /usr/share/wazuh-dashboard/bin/opensearch-dashboards \
    && sudo setcap 'cap_net_bind_service=+ep' /usr/share/wazuh-dashboard/node/fallback/bin/node
```

---

## Managing Custom Logo for Wazuh Dashboard
```bash
# Create required directories and set permissions
sudo mkdir -p /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images \
    && sudo chown -R wazuh:wazuh /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom \
    && sudo chmod -R 755 /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom

# Ensure logo file exists
sudo touch /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images/customization.logo.app.svg \
    && sudo chown wazuh-dashboard:wazuh-dashboard /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images/customization.logo.app.svg \
    && sudo chmod 664 /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images/customization.logo.app.svg
```

---

## Configuring Wazuh Configuration File
```bash
sudo chown wazuh-dashboard:wazuh-dashboard /usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml \
    && sudo chmod 644 /usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml
```

---

## Restarting Wazuh Services
```bash
# Restart and check all Wazuh services in one command
for service in wazuh-manager wazuh-dashboard wazuh-indexer; do 
    sudo systemctl restart $service && sudo systemctl status $service --no-pager; 
done
```

---

## Custom Branding (Title, Hostname, Boot, Banner)
```bash
# Set Web Title
sudo sed -i 's/applicationTitle:.*/applicationTitle: "Defendx - Unified XDR and SIEM"/' /etc/wazuh-dashboard/opensearch_dashboards.yml

# Change Hostname for Web Access
sudo sed -i 's/127.0.0.1.*/127.0.0.1 defendx/' /etc/hosts && sudo sed -i 's/::1.*/::1 defendx/' /etc/hosts

# Boot-up Logo
sudo curl -o /boot/grub2/defendx.png https://cdn.conzex.com/uploads/defendx.png && \
    echo 'GRUB_BACKGROUND="/boot/grub2/defendx.png"' | sudo tee -a /etc/default/grub && \
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Terminal Login Banner (MOTD)
echo "$(figlet -f big 'DefendX')" | sudo tee /etc/motd
```

---

## Clearing Cache
```bash
sudo rm -rf /usr/share/wazuh-dashboard/optimize/* && sudo systemctl restart wazuh-dashboard
```

---

## Troubleshooting Commands
```bash
# Check if custom logo file exists
ls -l /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images/

# Find key files
find /usr/share/wazuh-dashboard -type f -name "customization.logo.app.svg"
find /usr/share/wazuh-dashboard -type f -name "favicon.svg"
find /usr/share/wazuh-dashboard -type f -name "help_menu.tsx" 2>/dev/null
find /usr/share/wazuh-dashboard -type f -name "wazuh_agent.c"
