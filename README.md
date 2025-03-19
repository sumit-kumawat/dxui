# **DefendX - Unified XDR & SIEM**

**A powerful and secure setup script for rebranding Wazuh into DefendX.**

![DefendX](https://cdn.conzex.com/uploads/LOGO-SVG/cz-light.svg)

---

## 📌 **Features**

✅ Creates an `admin` user with sudo privileges.  
✅ Rebrands Wazuh with **DefendX** logos and branding.  
✅ Updates `/etc/issue` with custom branding details.  
✅ Changes hostname to `DefendX` and updates `/etc/hosts`.  
✅ Replaces **Wazuh Dashboard** branding.  
✅ Updates **boot logo** with DefendX branding.  
✅ Restarts all necessary Wazuh services after configuration.  

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
sudo apt update && sudo apt install -y curl
curl -sSL https://github.com/sumit-kumawat/dxui/raw/main/setup.sh | sudo bash
```
---

## 🔑 **Default Credentials**

| Parameter       | Value          |
|----------------|---------------|
| **Admin User** | `admin`       |
| **Password**   | `Adm1n@123`   |
| **Dashboard**  | `https://<server-ip>` |
| **Login**      | `admin` / `admin` |

---

## 🔄 **Restart Wazuh Services**

If needed, restart Wazuh services manually:

```bash
sudo systemctl restart wazuh-manager wazuh-indexer wazuh-dashboard
```

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

