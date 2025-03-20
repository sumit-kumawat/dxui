#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Define Colors
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Ensure script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}✖ This script must be run as root!${RESET}"
    exit 1
fi

# Creating user 'admin' with sudo privileges
echo -e "${BLUE}Creating user 'admin' with sudo privileges...${RESET}"
useradd -m -s /bin/bash admin
echo "admin:Adm1n@123" | chpasswd
usermod -aG wheel admin  # 'wheel' group for sudo on Amazon Linux
echo -e "${GREEN}✔ User 'admin' created successfully!${RESET}"

# Ensure admin user has passwordless sudo
echo "admin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/admin

# Switch to 'admin' and execute remaining steps as root
echo -e "${BLUE}Switching to user 'admin' and continuing setup as root...${RESET}"
su - admin -c "sudo bash -c '$(cat << 'EOF'

# Transferring ownership of 'wazuh-user' files to 'admin'
echo -e \"${BLUE}Transferring ownership of 'wazuh-user' files to 'admin'...${RESET}\"
if id \"wazuh-user\" &>/dev/null; then
    find / -user wazuh-user -exec chown admin:admin {} \; 2>/dev/null
    echo -e \"${GREEN}✔ Ownership transferred!${RESET}\"

    # Removing 'wazuh-user' from system
    echo -e \"${BLUE}Removing 'wazuh-user'...${RESET}\"
    pkill -u wazuh-user || true
    userdel -r wazuh-user || true
    echo -e \"${GREEN}✔ 'wazuh-user' removed successfully!${RESET}\"
else
    echo -e \"${YELLOW}✔ 'wazuh-user' does not exist, skipping removal.${RESET}\"
fi

# Update /etc/issue with DefendX Branding
echo -e "${BLUE}Updating /etc/issue with DefendX branding...${RESET}"
sudo bash -c 'cat << EOF > /etc/issue
🔹 Welcome to DefendX – Unified XDR & SIEM 🔹
📖 Documentation: docs.conzex.com/defendx
🌐 Website: www.conzex.com
📧 Support: defendx-support@conzex.com
EOF'
echo -e "${GREEN}✔ /etc/issue updated successfully!${RESET}"

# Set Hostname
echo -e "${BLUE}Setting hostname to: DefendX...${RESET}"
sudo hostnamectl set-hostname defendx
echo -e "${GREEN}✔ Hostname updated!${RESET}"

# Update Hosts File
echo -e "${BLUE}Updating Hosts File...${RESET}"
sudo bash -c 'echo -e "127.0.0.1   defendx\n::1         defendx" >> /etc/hosts'
echo -e "${GREEN}✔ Hosts file updated!${RESET}"

# Replace Wazuh Logo with DefendX Logo
echo -e "${BLUE}Replacing Wazuh logos with DefendX logos...${RESET}"
logo_url="https://cdn.conzex.com/uploads/Defendx-Assets/Wazuh-assets/30e500f584235c2912f16c790345f966.svg"
logo_locations=(
    "/usr/share/wazuh-dashboard/plugins/securityDashboards/target/public/30e500f584235c2912f16c790345f966.svg"
    "/usr/share/wazuh-dashboard/src/core/server/core_app/assets/30e500f584235c2912f16c790345f966.svg"
)

for location in "${logo_locations[@]}"; do
    if [ -f "$location" ]; then
        sudo curl -s -o "$location" "$logo_url"
        sudo chown wazuh:wazuh "$location"
        sudo chmod 644 "$location"
        echo -e "${GREEN}✔ Logo updated for: $location${RESET}"
    else
        echo -e "${RED}✖ Logo file not found: $location, skipping...${RESET}"
    fi
done
echo -e "${GREEN}✔ Logo replacement completed!${RESET}"

# Update get_logos.js for DefendX Branding
echo -e "${BLUE}Renaming Defendx Dashboard logos...${RESET}"
LOGO_JS_PATH="/usr/share/wazuh-dashboard/src/core/common/logos/get_logos.js"
sudo bash -c "cat << EOF > \$LOGO_JS_PATH
const OPENSEARCH_DASHBOARDS_THEMED = exports.OPENSEARCH_DASHBOARDS_THEMED = 'ui/logos/defendx_dashboards.svg';
const OPENSEARCH_DASHBOARDS_ON_LIGHT = exports.OPENSEARCH_DASHBOARDS_ON_LIGHT = 'ui/logos/defendx_dashboards_on_light.svg';
const OPENSEARCH_DASHBOARDS_ON_DARK = exports.OPENSEARCH_DASHBOARDS_ON_DARK = 'ui/logos/defendx_dashboards_on_dark.svg';
const OPENSEARCH_THEMED = exports.OPENSEARCH_THEMED = 'ui/logos/defendx.svg';
const OPENSEARCH_ON_LIGHT = exports.OPENSEARCH_ON_LIGHT = 'ui/logos/defendx_on_light.svg';
const OPENSEARCH_ON_DARK = exports.OPENSEARCH_ON_DARK = 'ui/logos/defendx_on_dark.svg';
const MARK_THEMED = exports.MARK_THEMED = 'ui/logos/defendx_mark.svg';
const MARK_ON_LIGHT = exports.MARK_ON_LIGHT = 'ui/logos/defendx_mark_on_light.svg';
const MARK_ON_DARK = exports.MARK_ON_DARK = 'ui/logos/defendx_mark_on_dark.svg';
const CENTER_MARK_THEMED = exports.CENTER_MARK_THEMED = 'ui/logos/defendx_center_mark.svg';
const CENTER_MARK_ON_LIGHT = exports.CENTER_MARK_ON_LIGHT = 'ui/logos/defendx_center_mark_on_light.svg';
const CENTER_MARK_ON_DARK = exports.CENTER_MARK_ON_DARK = 'ui/logos/defendx_center_mark_on_dark.svg';
const ANIMATED_MARK_THEMED = exports.ANIMATED_MARK_THEMED = 'ui/logos/spinner.svg';
const ANIMATED_MARK_ON_LIGHT = exports.ANIMATED_MARK_ON_LIGHT = 'ui/logos/spinner_on_light.svg';
const ANIMATED_MARK_ON_DARK = exports.ANIMATED_MARK_ON_DARK = 'ui/logos/spinner_on_dark.svg';
EOF"
echo -e "${GREEN}✔ Logos renamed in get_logos.js!${RESET}"

# Update Dashboard Branding
echo -e "${BLUE}Updating Dashboard Branding...${RESET}"
sudo sed -i '/opensearchDashboards.branding:/,/applicationTitle:/d' /etc/wazuh-dashboard/opensearch_dashboards.yml
sudo bash -c 'echo -e "opensearchDashboards.branding:\n  applicationTitle: \"DefendX - Unified XDR and SIEM\"" >> /etc/wazuh-dashboard/opensearch_dashboards.yml'
echo -e "${GREEN}✔ Dashboard branding updated successfully!${RESET}"

# Update Boot Logo
echo -e "${BLUE}Updating Boot Logo...${RESET}"
boot_logo_url="https://cdn.conzex.com/uploads/Defendx-Assets/defendx.png"
sudo curl -s -o /boot/grub2/defendx.png "$boot_logo_url"
sudo sed -i 's|^GRUB_BACKGROUND=.*|GRUB_BACKGROUND="/boot/grub2/defendx.png"|' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
echo -e "${GREEN}✔ Boot logo updated!${RESET}"

# Clear DefendX Dashboard Cache
echo -e "${BLUE}Clearing Wazuh Dashboard cache...${RESET}"
sudo rm -rf /usr/share/wazuh-dashboard/data/*
sudo systemctl restart wazuh-dashboard
echo -e "${GREEN}✔ Cache cleared successfully!${RESET}"

# Restart Services
echo -e "${BLUE}Restarting Wazuh Services...${RESET}"
for service in wazuh-manager wazuh-indexer wazuh-dashboard; do
    sudo systemctl restart $service
    sudo systemctl enable $service
    echo -e "${GREEN}✔ Service $service restarted successfully!${RESET}"
done

# Final Message
echo -e "${GREEN}✔ DefendX setup completed successfully!${RESET}"
echo -e "🔑 Login Credentials:"
echo -e "👤 User: admin"
echo -e "🔒 Password: Adm1n@123"
echo -e "🌐 Dashboard Login: http://$(hostname -I | awk '{print $1}') or $(hostname)"
echo -e "👤 Username: admin"
echo -e "🔒 Password: admin"
