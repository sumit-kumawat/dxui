#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Define Colors
GREEN="\e[1;32m"
BLUE="\e[1;34m"
RED="\e[1;31m"
YELLOW="\e[1;33m"
BOLD="\e[1m"
RESET="\e[0m"

# Ensure script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}✖ This script must be run as root!${RESET}"
    exit 1
fi

echo -e "${BLUE}${BOLD}🚀 Starting DefendX Setup...${RESET}"

# Creating user 'admin' with sudo privileges
echo -e "${BLUE}🔹 Creating user 'admin' with sudo privileges...${RESET}"
useradd -m -s /bin/bash admin || true
echo "admin:Adm1n@123" | chpasswd
usermod -aG wheel admin  # 'wheel' group for sudo on Amazon Linux
echo -e "${GREEN}✅ User 'admin' created successfully!${RESET}"

# Ensure admin user has passwordless sudo
echo "admin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/admin

# Switch to 'admin' and execute remaining steps
echo -e "${BLUE}🔹 Switching to user 'admin' and continuing setup...${RESET}"
su - admin -c "bash -s" << 'EOF'

echo -e "${BLUE}🔹 Transferring ownership of 'wazuh-user' files to 'admin'...${RESET}"
if id "wazuh-user" &>/dev/null; then
    sudo find / -user wazuh-user -exec chown admin:admin {} \; 2>/dev/null
    echo -e "${GREEN}✅ Ownership transferred!${RESET}"

    read -p "❓ Are you sure you want to delete 'wazuh-user'? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🔹 Removing 'wazuh-user'...${RESET}"
        sudo pkill -u wazuh-user || true
        sudo userdel -r wazuh-user || true
        echo -e "${GREEN}✅ 'wazuh-user' removed successfully!${RESET}"
    else
        echo -e "${YELLOW}⚠ 'wazuh-user' deletion skipped.${RESET}"
    fi
else
    echo -e "${YELLOW}⚠ 'wazuh-user' does not exist, skipping removal.${RESET}"
fi

# Set Hostname
echo -e "${BLUE}🔹 Setting hostname to: DefendX...${RESET}"
sudo hostnamectl set-hostname defendx
echo -e "${GREEN}✅ Hostname updated!${RESET}"

# Update Hosts File
echo -e "${BLUE}🔹 Updating Hosts File...${RESET}"
sudo bash -c 'echo -e "127.0.0.1   defendx\n::1         defendx" >> /etc/hosts'
echo -e "${GREEN}✅ Hosts file updated!${RESET}"

# Replace Wazuh Logo with DefendX Logo
echo -e "${BLUE}🔹 Replacing Wazuh logos with DefendX logos...${RESET}"
LOGO_PATHS=(
    "/usr/share/wazuh-dashboard/plugins/securityDashboards/target/public/30e500f584235c2912f16c790345f966.svg"
    "/usr/share/wazuh-dashboard/src/core/server/core_app/assets/30e500f584235c2912f16c790345f966.svg"
)

NEW_LOGO_PATH="https://cdn.conzex.com/uploads/Defendx-Assets/Wazuh-assets/30e500f584235c2912f16c790345f966.svg"  # Update with actual logo path

# Function to replace logos
replace_logos() {
    for FILE in "${LOGO_PATHS[@]}"; do
        if [[ -f "$FILE" ]]; then
            cp "$NEW_LOGO_PATH" "$FILE"
            echo "✅ Replaced: $FILE"
        else
            echo "✖ Logo file not found: $FILE, skipping..."
        fi
    done
}

# Ensure the new logo exists
if [[ ! -f "$NEW_LOGO_PATH" ]]; then
    echo "❌ Error: DefendX logo file is missing at $NEW_LOGO_PATH. Please provide the correct path."
    exit 1
fi

done
echo -e "${GREEN}✅ Logo replacement completed!${RESET}"

# Update get_logos.js for DefendX Branding
echo -e "${BLUE}🔹 Renaming Defendx Dashboard logos...${RESET}"
LOGO_JS_PATH="/usr/share/wazuh-dashboard/src/core/common/logos/get_logos.js"
sudo bash -c "cat > $LOGO_JS_PATH << 'EOL'
const OPENSEARCH_DASHBOARDS_THEMED = 'ui/logos/defendx_dashboards.svg';
const OPENSEARCH_DASHBOARDS_ON_LIGHT = 'ui/logos/defendx_dashboards_on_light.svg';
const OPENSEARCH_DASHBOARDS_ON_DARK = 'ui/logos/defendx_dashboards_on_dark.svg';
const OPENSEARCH_THEMED = 'ui/logos/defendx.svg';
const OPENSEARCH_ON_LIGHT = 'ui/logos/defendx_on_light.svg';
const OPENSEARCH_ON_DARK = 'ui/logos/defendx_on_dark.svg';
const MARK_THEMED = 'ui/logos/defendx_mark.svg';
const MARK_ON_LIGHT = 'ui/logos/defendx_mark_on_light.svg';
const MARK_ON_DARK = 'ui/logos/defendx_mark_on_dark.svg';
const CENTER_MARK_THEMED = 'ui/logos/defendx_center_mark.svg';
const CENTER_MARK_ON_LIGHT = 'ui/logos/defendx_center_mark_on_light.svg';
const CENTER_MARK_ON_DARK = 'ui/logos/defendx_center_mark_on_dark.svg';
const ANIMATED_MARK_THEMED = 'ui/logos/spinner.svg';
const ANIMATED_MARK_ON_LIGHT = 'ui/logos/spinner_on_light.svg';
const ANIMATED_MARK_ON_DARK = 'ui/logos/spinner_on_dark.svg';
EOL"
echo -e "${GREEN}✅ Logos renamed in get_logos.js!${RESET}"

# Update /etc/issue with DefendX Branding
echo -e "${BLUE}🔹 Updating /etc/issue with DefendX branding...${RESET}"
sudo bash -c 'cat << EOL > /etc/issue
🔹 Welcome to DefendX – Unified XDR & SIEM 🔹

📖 Documentation: docs.conzex.com/defendx
🌐 Website: www.conzex.com
📧 Support: defendx-support@conzex.com
_______________________________________________________________________
echo -e "👤 User: admin"
echo -e "🔒 Password: Adm1n@123"

EOL'
echo -e "${GREEN}✅ /etc/issue updated successfully!${RESET}"

# Restart Services
echo -e "${BLUE}🔹 Restarting Wazuh Services...${RESET}"
for service in wazuh-manager wazuh-indexer wazuh-dashboard; do
    sudo systemctl restart $service
    sudo systemctl enable $service
    echo -e "${GREEN}✅ Service $service restarted successfully!${RESET}"
done

# Display service status
echo -e "${BLUE}🔹 Checking service status...${RESET}"
services=(wazuh-manager wazuh-indexer wazuh-dashboard)
status_line=""
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        status_line+="${GREEN}$service: Running${RESET} | "
    else
        status_line+="${RED}$service: Stopped${RESET} | "
    fi
done

echo -e "Service Status: ${status_line% | }"

# Final Message
echo -e "${GREEN}${BOLD}✅ DefendX setup completed successfully!${RESET}"
echo -e "🔑 ${BOLD}Login Credentials:${RESET}"
echo -e "👤 User: admin"
echo -e "🔒 Password: Adm1n@123"
echo -e "🌐 Dashboard Login: https://$(hostname -I | awk '{print $1}')"
echo -e "👤 Username: admin"
echo -e "🔒 Password: admin"
echo -e "${GREEN}${BOLD}🚀 DefendX Setup completed successfully!${RESET}"

EOF
