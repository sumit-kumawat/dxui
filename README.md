# DefendX Branding Script

## Overview
This script automates the branding and setup of the security dashboard to **DefendX**, replacing existing logos, updating configurations, and applying security settings.

## Features
✅ Creates an `admin` user with sudo privileges  
✅ Transfers ownership of `wazuh-user` files to `admin`  
✅ Removes the `wazuh-user` if it exists  
✅ Updates `/etc/issue` with **DefendX branding**  
✅ Sets hostname to `DefendX`  
✅ Updates hosts file for correct resolution  
✅ Replaces existing logos with **DefendX logos**  
✅ Configures dashboard title and system banners  
✅ Updates boot logo to **DefendX branding**  
✅ Ensures correct file ownership and permissions  
✅ Restarts necessary services  
✅ Displays login credentials and access URLs after completion  

## Prerequisites
- Wazuh security dashboard must be installed.
- Ensure you have `sudo` privileges.
- Ensure internet access to download branding assets.

## Installation & Usage
1. **Clone the repository (if applicable) or manually download the script.**
   ```bash
   git clone https://github.com/sumit-kumawat/dxui.git
   cd dxui
   ```

2. **Make the script executable:**
   ```bash
   chmod +x setup.sh
   ```

3. **Run the script with sudo:**
   ```bash
   sudo ./setup.sh
   ```

## Branding Changes
- Creates an `admin` user with predefined credentials.
- Transfers all files owned by `wazuh-user` to `admin` and removes `wazuh-user`.
- Replaces existing dashboard logo with **DefendX logo**.
- Updates **dashboard title** to `DefendX - Unified XDR and SIEM`.
- Configures **boot logo** and **terminal login banner**.
- Updates **system hostname** to `defendx`.
- Ensures all services are restarted and enabled for persistence.

## Troubleshooting
If branding does not apply correctly:
1. Check logs:
   ```bash
   sudo journalctl -xe
   sudo systemctl status wazuh-dashboard
   ```
2. Manually clear dashboard cache:
   ```bash
   sudo rm -rf /usr/share/wazuh-dashboard/optimize/*
   sudo systemctl restart wazuh-dashboard
   ```

## License
This project is licensed under the **MIT License**.

## Contact
For support, contact **defendx-support@conzex.com**.
