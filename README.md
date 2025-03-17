# Wazuh Dashboard Setup Script

This script automates the setup and configuration of the Wazuh Dashboard, including system preparation, permission setup, and post-installation configurations.

## Features:
- Updates system packages.
- Disables IPv6 to enhance security.
- Sets a custom hostname (`defendx`).
- Configures Dashboard permissions.
- Allows binding to privileged ports.
- Manages a custom logo and asset directory.
- Ensures correct ownership and permissions for configuration files.
- Restarts services and verifies their status.

## Prerequisites:
- Root privileges are required to run this script.
- A working Wazuh installation should be present on the system.

## Steps to Follow:

### 1. Download the Script:
Run the following command to download the script from GitHub:

```bash
curl -O curl -O https://raw.githubusercontent.com/sumit-kumawat/wzui/main/setup.sh
```

```bash
chmod +x setup.sh
```

```bash
sudo ./setup.sh
```
