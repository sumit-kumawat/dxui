# DefendX UI Branding Script

This script updates the branding of Wazuh UI to DefendX by replacing logos and ensuring the correct directory permissions.

## Features
- Replaces Wazuh branding with DefendX branding.
- Downloads the latest DefendX logo assets.
- Ensures correct file ownership and permissions.
- Restarts the DefendX dashboard service for changes to take effect.

## Installation & Usage

### Prerequisites
- A running instance of Wazuh Dashboard.
- `curl` installed on your system.
- `sudo` privileges.

### Steps to Execute
1. Clone the repository:
   ```sh
   git clone https://github.com/sumit-kumawat/wzui.git
   cd wzui
   ```
2. Make the script executable:
   ```sh
   chmod +x wzui-setup.sh
   ```
3. Run the script:
   ```sh
   sudo ./wzui-setup.sh
   ```

### Expected Output
- The script will fetch and replace the Wazuh logo with the DefendX logo.
- It will check and correct directory permissions.
- It will restart the Wazuh (DefendX) dashboard service.
- A confirmation message will be displayed upon successful execution.

## Troubleshooting
If the dashboard does not reflect the changes:
- Clear your browser cache.
- Manually restart the dashboard:
  ```sh
  sudo systemctl restart wazuh-dashboard
  ```
- Ensure the logo URLs are accessible.

## License
This script is open-source and can be modified to fit your branding requirements.

## Contact
For support, reach out via:
- **Email**: dx-support@conzex.com
- **Website**: [DefendX](https://www.defendx.io)

