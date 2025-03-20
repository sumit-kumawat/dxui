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

# Step 1: Creating user 'admin' with sudo privileges
echo -e "${BLUE}🔹 Creating user 'admin' with sudo privileges...${RESET}"
useradd -m -s /bin/bash admin || true
echo "admin:Adm1n@123" | chpasswd
usermod -aG wheel admin  # 'wheel' group for sudo on Amazon Linux
echo "admin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/admin
echo -e "${GREEN}✅ User 'admin' created successfully!${RESET}"

# Step 2: Set Hostname and Update Hosts File
echo -e "${BLUE}🔹 Setting hostname to: DefendX...${RESET}"
hostnamectl set-hostname defendx
echo -e "127.0.0.1   defendx\n::1         defendx" >> /etc/hosts
echo -e "${GREEN}✅ Hostname and Hosts file updated!${RESET}"

# Step 3: Transfer ownership of 'wazuh-user' files to 'admin' if it exists
if id "wazuh-user" &>/dev/null; then
    echo -e "${BLUE}🔹 Transferring ownership of 'wazuh-user' files to 'admin'...${RESET}"
    
    # Define target directories to scan instead of full system scan
    for dir in /home /var /opt /usr/local; do
        find "$dir" -user wazuh-user -exec chown admin:admin {} + 2>/dev/null
    done

    echo -e "${GREEN}✅ Ownership transferred!${RESET}"

# Step 4: Download and Extract Assets
echo -e "${BLUE}🔹 Downloading assets from DefendX CDN...${RESET}"
mkdir -p /tmp/defendx-assets

# Download assets with error handling
if ! curl -L -o /tmp/defendx-assets/assets.zip <ASSETS_ZIP_URL>; then
    echo -e "${RED}❌ Failed to download assets! Check the URL or network.${RESET}"
    exit 1
fi

# Validate the ZIP file
if ! unzip -t /tmp/defendx-assets/assets.zip &>/dev/null; then
    echo -e "${RED}❌ Downloaded assets are corrupt. Retrying...${RESET}"
    rm -f /tmp/defendx-assets/assets.zip
    sleep 5  # Wait before retry
    curl -L -o /tmp/defendx-assets/assets.zip <ASSETS_ZIP_URL>
fi

# Extract assets
if unzip -o /tmp/defendx-assets/assets.zip -d /tmp/defendx-assets; then
    echo -e "${GREEN}✅ Assets downloaded and extracted successfully!${RESET}"
else
    echo -e "${RED}❌ Extraction failed! Check if assets.zip is valid.${RESET}"
    exit 1
fi


# Step 5: Replace Logos
echo -e "${BLUE}🔹 Replacing Wazuh logos with DefendX logos...${RESET}"
LOGO_PATHS=(
    "/usr/share/wazuh-dashboard/plugins/securityDashboards/target/public/30e500f584235c2912f16c790345f966.svg"
)
NEW_LOGO_PATH="$TARGET_DIR/30e500f584235c2912f16c790345f966.svg"

for FILE in "${LOGO_PATHS[@]}"; do
    if [[ -f "$FILE" ]]; then
        cp "$NEW_LOGO_PATH" "$FILE"
        echo "✅ Replaced: $FILE"
    else
        echo "✖ Logo file not found: $FILE, skipping..."
    fi
done
echo -e "${GREEN}✅ Logo replacement completed!${RESET}"

# Step 6: Update Branding Files
echo -e "${BLUE}🔹 Updating get_logos.js for DefendX Branding...${RESET}"
LOGO_JS_PATH="/usr/share/wazuh-dashboard/src/core/common/logos/get_logos.js"
sudo bash -c "cat > $LOGO_JS_PATH << 'EOL'
const OPENSEARCH_DASHBOARDS_THEMED = 'ui/logos/defendx_dashboards.svg';
const OPENSEARCH_DASHBOARDS_ON_LIGHT = 'ui/logos/defendx_dashboards_on_light.svg';
const OPENSEARCH_DASHBOARDS_ON_DARK = 'ui/logos/defendx_dashboards_on_dark.svg';
const OPENSEARCH_THEMED = 'ui/logos/defendx.svg';
const OPENSEARCH_ON_LIGHT = 'ui/logos/defendx_on_light.svg';
const OPENSEARCH_ON_DARK = 'ui/logos/defendx_on_dark.svg';
EOL"
echo -e "${GREEN}✅ Logos renamed in get_logos.js!${RESET}"

# Step 7: Update /etc/issue for Branding
echo -e "${BLUE}🔹 Updating /etc/issue with DefendX branding...${RESET}"
cat << EOL > /etc/issue
🔹 Welcome to DefendX – Unified XDR & SIEM 🔹
📖 Documentation: docs.conzex.com/defendx
🌐 Website: www.conzex.com
📧 Support: defendx-support@conzex.com
_______________________________________________________________________
👤 User: admin
🔒 Password: Adm1n@123
EOL
echo -e "${GREEN}✅ /etc/issue updated successfully!${RESET}"

# Step 8: Restart Wazuh Services
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

# Step 9: Check Service Status
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

# Final Message
echo -e "${GREEN}${BOLD}✅ DefendX setup completed successfully!${RESET}"
echo -e "🌐 Dashboard Login: https://$(hostname -I | awk '{print $1}')"
echo -e "👤 User: admin"
echo -e "🔒 Password: Adm1n@123"
