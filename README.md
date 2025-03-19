# DefendX Branding Script

## Overview
This script automates the branding and setup of the security dashboard to **DefendX**, replacing existing logos, updating configurations, and applying security settings.

## Features
✅ Updates system packages & disables IPv6  
✅ Sets hostname to `DefendX`  
✅ Downloads and applies DefendX branding assets  
✅ Replaces existing logos with DefendX logos  
✅ Configures dashboard title and system banners  
✅ Ensures correct file ownership and permissions  
✅ Enables privileged port binding  
✅ Restarts services and clears cache  

## Prerequisites
- The security dashboard must be installed.
- Ensure you have `sudo` privileges.
- Ensure internet access to download branding assets.

## Installation & Usage
1. **Clone the repository (if applicable) or manually download the script.**
   ```bash
   git clone https://github.com/sumit-kumawat/dxui.git
   cd wzui
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
- Replaces existing dashboard logo with **DefendX logo**.
- Updates **dashboard title** to `DefendX - Unified XDR and SIEM`.
- Configures **boot logo** and **terminal login banner**.
- Updates **system hostname** to `defendx`.

## Troubleshooting
If branding does not apply correctly:
1. Check logs:
   ```bash
   sudo journalctl -xe
   sudo systemctl status dashboard-service
   ```
2. Manually clear dashboard cache:
   ```bash
   sudo rm -rf /usr/share/dashboard/optimize/*
   sudo systemctl restart dashboard-service
   ```

## License
This project is licensed under the **MIT License**.

## Contact
For support, contact **defendx-support@conzex.com**.
