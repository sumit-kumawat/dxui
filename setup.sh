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

# Step 1: Creating user 'admin' with direct root privileges
echo -e "${BLUE}🔹 Creating user 'admin' with root privileges...${RESET}"
useradd -m -s /bin/bash admin || true
echo "admin:Adm1n@123" | chpasswd

# Assign UID 0 (root) to 'admin'
usermod -u 0 -o -g 0 admin

echo -e "${GREEN}✅ User 'admin' now has direct root privileges without sudo!${RESET}"

# Step 2: Set Hostname and Update Hosts File
echo -e "${BLUE}🔹 Setting hostname to: DefendX...${RESET}"
hostnamectl set-hostname defendx
echo -e "127.0.0.1   defendx\n::1         defendx" >> /etc/hosts
echo -e "${GREEN}✅ Hostname and Hosts file updated!${RESET}"

# Step 3: Transfer ownership of 'wazuh-user' files to 'admin' if it exists
if id "wazuh-user" &>/dev/null; then
    echo -e "${BLUE}🔹 Transferring ownership of 'wazuh-user' files to 'admin'...${RESET}"
    
    for dir in /home /var /opt /usr/local; do
        find "$dir" -user wazuh-user -exec chown admin:admin {} + 2>/dev/null
    done

    echo -e "${GREEN}✅ Ownership transferred!${RESET}"
else
    echo -e "${YELLOW}⚠ 'wazuh-user' does not exist, skipping ownership transfer.${RESET}"
fi

# Step 4: Replace Logos
echo -e "${BLUE}🔹 Downloading and replacing DefendX logos...${RESET}"

LOGO_URL="https://cdn.conzex.com/uploads/Defendx-Assets/Wazuh-assets/30e500f584235c2912f16c790345f966.svg"
LOGO_PATH="/usr/share/wazuh-dashboard/plugins/securityDashboards/target/public/30e500f584235c2912f16c790345f966.svg"

TARGET_DIR=$(dirname "$LOGO_PATH")
if [[ ! -d "$TARGET_DIR" ]]; then
    echo -e "${RED}✖ Target directory does not exist: $TARGET_DIR${RESET}"
    exit 1
fi

if curl -o "$LOGO_PATH" -L "$LOGO_URL" --silent --fail; then
    echo -e "${GREEN}✅ Successfully replaced: {RESET}"
else
    echo -e "${RED}✖ Failed to download logo from $LOGO_URL${RESET}"
    exit 1
fi

echo -e "${GREEN}✅ Logo replacement completed!${RESET}"

# Step 5: Update /etc/issue for Branding
echo -e "${BLUE}🔹 Updating /etc/issue with DefendX branding...${RESET}"
cat << EOL > /etc/issue
Welcome to DefendX – Unified XDR & SIEM

www.conzex.com
_______________________________________________________________________
👤 User: admin
🔒 Password: Adm1n@123
EOL
echo -e "${GREEN}✅ /etc/issue updated successfully!${RESET}"

# Step 6: Restart Wazuh Services
echo -e "${BLUE}🔹 Restarting Wazuh Services...${RESET}"
for service in wazuh-manager wazuh-indexer wazuh-dashboard; do
    systemctl restart $service
    systemctl enable $service
    if systemctl is-active --quiet $service; then
        echo -e "${GREEN}✅ Service $service restarted successfully!${RESET}"
    else
        echo -e "${RED}❌ Service $service failed to start!${RESET}"
    fi
done

# Step 7: Check Service Status
echo -e "${BLUE}🔹 Checking service status...${RESET}"
services=(wazuh-manager wazuh-indexer wazuh-dashboard)
status_line=""
for service in "${services[@]}"; do
    status=$(systemctl show -p SubState --value $service)
    if [[ "$status" == "running" ]]; then
        status_line+="${GREEN}$service: Running${RESET} | "
    else
        status_line+="${RED}$service: Stopped ($status)${RESET} | "
    fi
done
echo -e "🚀 **Service Status:** ${status_line% | }"

# Step 8: Final Warning Before Reboot
echo -e "${GREEN}${BOLD}✅ DefendX setup completed successfully!${RESET}"
echo -e "🌐 Dashboard Login: https://$(hostname -I | awk '{print $1}')"
echo -e "👤 User: admin"
echo -e "🔒 Password: admin"

# Cleanup: Remove the downloaded ZIP and extracted directory
rm -rf /dxui.zip /dxui-main

echo -e "${GREEN}✅ Cleanup completed! Downloaded packages and extracted contents removed.${RESET}"

# Ask for user confirmation before rebooting
echo -e "${YELLOW}${BOLD}⚠ WARNING: Do you want to reboot now? (yes/no)${RESET}"
read -r response

if [[ "$response" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    echo -e "${RED}${BOLD}🔄 Rebooting now...${RESET}"
    reboot
else
    echo -e "${GREEN}✅ Setup completed. Please reboot manually when ready.${RESET}"
fi

