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
useradd -m -s /bin/bash admin || true
echo "admin:Adm1n@123" | chpasswd
usermod -aG wheel admin  # 'wheel' group for sudo on Amazon Linux
echo -e "${GREEN}✔ User 'admin' created successfully!${RESET}"

# Ensure admin user has passwordless sudo
echo "admin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/admin

# Switch to 'admin' and execute remaining steps
echo -e "${BLUE}Switching to user 'admin' and continuing setup as root...${RESET}"
su - admin -c "bash -s" << 'EOF'
echo -e "\e[34mTransferring ownership of 'wazuh-user' files to 'admin'...\e[0m"
if id "wazuh-user" &>/dev/null; then
    sudo find / -user wazuh-user -exec chown admin:admin {} \; 2>/dev/null
    echo -e "\e[32m✔ Ownership transferred!\e[0m"

    echo -e "\e[34mRemoving 'wazuh-user'...\e[0m"
    sudo pkill -u wazuh-user || true
    sudo userdel -r wazuh-user || true
    echo -e "\e[32m✔ 'wazuh-user' removed successfully!\e[0m"
else
    echo -e "\e[33m✔ 'wazuh-user' does not exist, skipping removal.\e[0m"
fi

# Update /etc/issue with DefendX Branding
echo -e "${BLUE}Updating /etc/issue with DefendX branding...${RESET}"
sudo bash -c 'cat << EOL > /etc/issue
🔹 Welcome to DefendX – Unified XDR & SIEM 🔹
📖 Documentation: docs.conzex.com/defendx
🌐 Website: www.conzex.com
📧 Support: defendx-support@conzex.com
EOL'
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
sudo bash -c "cat > $LOGO_JS_PATH << 'EOL'
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
EOL"
echo -e "${GREEN}✔ Logos renamed in get_logos.js!${RESET}"

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
EOF

echo "Defendx Setup completed successfully!"
