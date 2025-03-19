#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Define Colors
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Creating user 'admin' with sudo privileges
echo -e "${BLUE}Creating user 'admin' with sudo privileges...${RESET}"
sudo useradd -m -s /bin/bash admin
echo "admin:Adm1n@123" | sudo chpasswd
sudo usermod -aG sudo admin
echo -e "${GREEN}✔ User 'admin' created successfully!${RESET}"

# Transferring ownership of 'wazuh-user' files to 'admin'
echo -e "${BLUE}Transferring ownership of 'wazuh-user' files to 'admin'...${RESET}"
if id "wazuh-user" &>/dev/null; then
    sudo find / -user wazuh-user -exec chown admin:admin {} \; 2>/dev/null
    echo -e "${GREEN}✔ Ownership transferred!${RESET}"

    # Removing 'wazuh-user' from system
    echo -e "${BLUE}Removing 'wazuh-user'...${RESET}"
    sudo deluser wazuh-user
    sudo pkill -u wazuh-user || true
    sudo userdel -r wazuh-user
    echo -e "${GREEN}✔ 'wazuh-user' removed successfully!${RESET}"
else
    echo -e "${YELLOW}✔ 'wazuh-user' does not exist, skipping removal.${RESET}"
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
sudo bash -c 'echo -e "127.0.0.1   defendx\n::1         defend" >> /etc/hosts'
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
        sudo cp "$location" "$location.bak"
        echo -e "${YELLOW}✔ Backup created for: $location${RESET}"
    fi
    sudo curl -s -o "$location" "$logo_url"
    sudo chown wazuh:wazuh "$location"
    sudo chmod 644 "$location"
done
echo -e "${GREEN}✔ Logo replacement completed!${RESET}"

# Update Dashboard Branding
echo -e "${BLUE}Updating Dashboard Branding...${RESET}"
sudo sed -i '/opensearchDashboards.branding:/,/applicationTitle:/d' /etc/wazuh-dashboard/opensearch_dashboards.yml
sudo bash -c 'echo -e "opensearchDashboards.branding:\n  applicationTitle: \"DefendX - Unified XDR and SIEM\"" >> /etc/wazuh-dashboard/opensearch_dashboards.yml'
echo -e "${GREEN}✔ Dashboard branding updated successfully!${RESET}"

# Update Boot Logo
echo -e "${BLUE}Updating Boot Logo...${RESET}"
sudo curl -s -o /boot/grub2/defendx.png https://cdn.conzex.com/uploads/Defendx-Assets/defendx.png
sudo sed -i 's|^GRUB_BACKGROUND=.*|GRUB_BACKGROUND="/boot/grub2/defendx.png"|' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
echo -e "${GREEN}✔ Boot logo updated!${RESET}"

# Restart Services
echo -e "${BLUE}Restarting Wazuh Services...${RESET}"
for service in wazuh-manager wazuh-indexer wazuh-dashboard; do
    sudo systemctl restart $service
    sudo systemctl enable $service
    sudo systemctl status $service --no-pager
    echo -e "${GREEN}✔ Service $service restarted successfully!${RESET}"
done

echo -e "${GREEN}✔ DefendX setup completed successfully!${RESET}"
echo -e "🔑 Login Credentials:"
echo -e "👤 User: admin"
echo -e "🔒 Password: Adm1n@123"
echo -e "🌐 Dashboard Login: http://$(hostname -I | awk '{print $1}') or $(hostname)"
echo -e "🖥 Username: admin"
echo -e "🖥 Password: admin"
