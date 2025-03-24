# **DefendX - Unified XDR & SIEM**

**A powerful and secure setup script for rebranding Wazuh into DefendX.**

![DefendX](https://cdn.conzex.com/uploads/LOGO-SVG/cz-light.svg)

---

## 📌 **Features**

✅ Creates an `admin` user with root privileges.  
✅ Rebrands Wazuh with **DefendX** logos and branding.  
✅ Updates `/etc/issue` with custom branding details.  
✅ Changes hostname to `DefendX` and updates `/etc/hosts`.  
✅ Replaces **Wazuh Dashboard** branding.  
✅ Updates **boot logo** with DefendX branding.  
✅ Restarts all necessary Wazuh services after configuration.  
✅ Transfers `wazuh-user` files to `admin` user.  
✅ Ensures all services are running after setup.  

---

## 📜 **Prerequisites**

Ensure your system has:
- A fresh **Wazuh installation**
- Internet access for downloading assets
- Root or sudo privileges

---

## 🛠 **Installation & Usage**

Run the following commands to set up **DefendX** on your Wazuh instance:

```bash
curl -L -o dxui.zip https://github.com/sumit-kumawat/dxui/archive/refs/heads/main.zip
unzip dxui.zip && cd dxui-main
chmod +x setup.sh
sudo ./setup.sh
```

---

## 🔑 **Default Credentials**

| Parameter       | Value          |
|----------------|---------------|
| **Admin User** | `admin`       |
| **Password**   | `Adm1n@123`   |
| **Dashboard URL** | `https://<server-ip>` |
| **Login Credentials** | `admin` / `admin` |

---

## 🔄 **Restart Wazuh Services**

If needed, restart Wazuh services manually:

```bash
sudo systemctl restart wazuh-manager wazuh-indexer wazuh-dashboard
```

---

## 🚀 **Script Workflow**

1. **Set Hostname:** Updates system hostname to `defendx` and modifies `/etc/hosts`.
2. **Update Wazuh Dashboard Branding:** Modifies `opensearch_dashboards.yml` for branding.
3. **Create Admin User:** Ensures `admin` user exists with root privileges.
4. **Transfer Ownership:** Transfers files from `wazuh-user` to `admin`.
5. **Replace Logos:** Downloads and updates Wazuh dashboard branding with DefendX assets.
6. **Update Branding in /etc/issue:** Adds DefendX branding to system login banner.
7. **Restart Services:** Ensures all Wazuh services restart and run properly.
8. **Final Confirmation:** Prompts for reboot to finalize setup.

---

## 🛡 **Security & Hardening**

- Change the default password **immediately after setup**.
- Restrict SSH access with a firewall.
- Enable automatic security updates.

---

## 📧 **Support & Contact**

📖 Documentation: [docs.conzex.com/defendx](https://docs.conzex.com/defendx)  
🌐 Website: [www.conzex.com](https://www.conzex.com)  
📧 Email: [defendx-support@conzex.com](mailto:defendx-support@conzex.com)  

---

🚀 **Enjoy enhanced security and monitoring with DefendX!** 🔥

