#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Define Colors
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Progress Bar Function
show_progress() {
    local pid=$1
    local delay=0.1
    local spin='|/-\'
    while ps -p $pid > /dev/null; do
        local i=$(( (i+1) %4 ))
        printf "\r${YELLOW}Processing... ${spin:$i:1}${RESET}"
        sleep $delay
    done
    printf "\r${GREEN}✔ Done!${RESET}\n"
}

# Function to check and create directories with correct permissions
check_and_create_dir() {
    local dir=$1
    local owner=$2
    local permissions=$3
    echo -e "${BLUE}Checking directory:${RESET} $dir"
    if [ ! -d "$dir" ]; then
        sudo mkdir -p "$dir"
        echo -e "${GREEN}✔ Created:${RESET} $dir"
    else
        echo -e "${YELLOW}✔ Already Exists:${RESET} $dir"
    fi
    sudo chown -R "$owner" "$dir"
    sudo chmod -R "$permissions" "$dir"
}

# Function to download files from a URL and preserve names
fetch_files() {
    local url=$1
    local destination=$2
    echo -e "${BLUE}Downloading files from:${RESET} $url"
    wget -q --show-progress -r -np -nH --cut-dirs=3 -R "index.html*" "$url" -P "$destination" &
    show_progress $!
}

# Function to replace logos
replace_logo() {
    local logo_url="https://cdn.conzex.com/uploads/Defendx-Assets/Wazuh-assets/30e500f584235c2912f16c790345f966.svg"
    local locations=(
        "/usr/share/wazuh-dashboard/plugins/securityDashboards/target/public/30e500f584235c2912f16c790345f966.svg"
        "/usr/share/wazuh-dashboard/src/core/server/core_app/assets/30e500f584235c2912f16c790345f966.svg"
    )

    for location in "${locations[@]}"; do
        if [ -f "$location" ]; then
            sudo cp "$location" "$location.bak"
            echo -e "${YELLOW}✔ Backup created for:${RESET} $location"
        fi

        echo -e "${BLUE}Replacing logo in:${RESET} $location"
        sudo curl -s -o "$location" "$logo_url"

        # Set correct ownership and permissions
        sudo chown wazuh:wazuh "$location"
        sudo chmod 644 "$location"
    done
}

# System Preparation
echo -e "${BLUE}Updating System...${RESET}"
sudo yum update -y & show_progress $!

# Disable IPv6
echo -e "${BLUE}Disabling IPv6...${RESET}"
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# Set Hostname
echo -e "${BLUE}Setting hostname to:${RESET} DefendX"
sudo hostnamectl set-hostname defendx

# Ensure all required directories exist with proper permissions
check_and_create_dir "/usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images" "wazuh:wazuh" "755"
check_and_create_dir "/usr/share/wazuh-dashboard/src/core/server/core_app/assets/" "wazuh:wazuh" "755"
check_and_create_dir "/usr/share/wazuh-dashboard/data/wazuh/config" "wazuh-dashboard:wazuh-dashboard" "644"
check_and_create_dir "/usr/share/wazuh-dashboard/data/wazuh/downloads" "wazuh-dashboard:wazuh-dashboard" "775"

# Fetch branding assets
fetch_files "https://cdn.conzex.com/?path=%2FDefendx-Assets%2FCustom+branding" "/usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images/"
fetch_files "https://cdn.conzex.com/?path=%2FDefendx-Assets%2FWazuh-assets" "/usr/share/wazuh-dashboard/src/core/server/core_app/assets/"

# Replace Wazuh logos with DefendX logos
replace_logo

# Change Ownership & Permissions for Wazuh Dashboard
echo -e "${BLUE}Setting ownership for Wazuh Dashboard...${RESET}"
sudo chown -R wazuh:wazuh /usr/share/wazuh-dashboard
sudo chmod -R 775 /usr/share/wazuh-dashboard

# Allow Binding to Privileged Ports
echo -e "${BLUE}Enabling port bindings...${RESET}"
sudo setcap 'cap_net_bind_service=+ep' /usr/share/wazuh-dashboard/bin/opensearch-dashboards
sudo setcap 'cap_net_bind_service=+ep' /usr/share/wazuh-dashboard/node/fallback/bin/node

# Restart Wazuh Services
echo -e "${BLUE}Restarting Wazuh Services...${RESET}"
for service in wazuh-manager wazuh-indexer wazuh-dashboard; do
    sudo systemctl restart $service
    sudo systemctl status $service --no-pager
done

# Set Web Title
echo -e "${BLUE}Setting Dashboard Title...${RESET}"
sudo sed -i '/opensearchDashboards.branding:/a applicationTitle: "DefendX - Unified XDR and SIEM"' /etc/wazuh-dashboard/opensearch_dashboards.yml

# Update Hosts File for Web Access
echo -e "${BLUE}Updating Hosts File...${RESET}"
sudo bash -c 'echo -e "127.0.0.1   defendx\n::1         defend" >> /etc/hosts'

# Update Boot-up Text & Logo
echo -e "${BLUE}Updating Boot Logo...${RESET}"
sudo curl -s -o /boot/grub2/defendx.png https://cdn.conzex.com/uploads/Defendx-Assets/defendx.png
sudo sed -i 's|^GRUB_BACKGROUND=.*|GRUB_BACKGROUND="/boot/grub2/defendx.png"|' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Clear Cache & Restart Dashboard
echo -e "${BLUE}Clearing Cache and Restarting Dashboard...${RESET}"
sudo rm -rf /usr/share/wazuh-dashboard/optimize/*
sudo systemctl restart wazuh-dashboard

# Troubleshooting Commands
echo -e "${YELLOW}Verifying Branding Files...${RESET}"
ls -l /usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images/
find /usr/share/wazuh-dashboard -type f -name "customization.logo.app.svg"
find /usr/share/wazuh-dashboard -type f -name "favicon.svg"
find /usr/share/wazuh-dashboard/ -type f -name "wazuh_agent.c"

# Completion Message
echo -e "${GREEN}✔ DefendX Dashboard setup & branding completed successfully!${RESET}"
