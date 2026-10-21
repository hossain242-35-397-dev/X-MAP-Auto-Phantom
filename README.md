# X-MAP-Auto-Phantom
An automated, cinematic Evil Twin attack framework for wireless penetration testing (2.4GHz &amp; 5GHz) with Captive Portal credential harvesting.




# 🚀 X-MAP Auto-Phantom (Wireless Evil Twin Toolkit)

Welcome! **X-MAP** is an automated wireless hacking tool built for Kali Linux to perform Evil Twin attacks. It can scan 2.4GHz and 5GHz networks, deauthenticate victims, and trap them using a fake captive portal login page to harvest Wi-Fi credentials.

> ⚠️ **DISCLAIMER:** This tool is strictly for **educational purposes and authorized lab environments only**. Using this against networks you do not own or have explicit permission to test is illegal and strictly prohibited.

---

## ✨ Features

*   **2.4GHz & 5GHz Scanning:** Choose to scan only 2.4G, only 5G, or both simultaneously.
*   **Victim Sniffing:** Automatically detects how many devices are connected to the target network.
*   **Multi-Target Selection:** Attack specific devices (by selecting their MAC addresses) or launch a broadcast attack on all devices at once.
*   **Smart Fake AP:** Automatically detects if the target is 2.4GHz or 5GHz and configures the fake AP (`hostapd`) accordingly.
*   **Captive Portal Trap:** Victims are presented with a fake login page to capture their Wi-Fi passwords.
*   **Cinematic UI:** A premium, neon-themed hacker terminal interface with colored logs.

---

## 🛠️ Prerequisites (What You Need)

1.  **Kali Linux** installed on your laptop.
2.  An **External Wi-Fi Adapter** (e.g., TP-Link, Alfa, Realtek) that supports **Monitor Mode** and **Packet Injection**.
3.  The adapter must be named `wlan1` (If your interface is named differently, you must change it in the script).
4.  Internet connection (only for the initial installation).

---

## 📥 Installation (For New Machines)

Follow these steps on a fresh Kali Linux machine:

### Step 1: Clone the Repository
Open your terminal and run:
```bash



Step 1: git clone https://github.com/hossain242-35-397-dev/X-MAP-Auto-Phantom.git
cd X-MAP-Auto-Phantom







Step 2: Run the Automated Installer
This command will install all required dependencies (Apache, Hostapd, Dnsmasq, etc.) and set up the captive portal:

bash
chmod +x install.sh
sudo ./install.sh
Step 3: Launch the Attack Tool
Once the installation is complete, start the tool:

bash
chmod +x phantom.sh
sudo ./phantom.sh
🎮 How to Use (Step-by-Step Guide)
After launching the script, follow the on-screen prompts:

1. Select Scan Band:

Enter 1 for 2.4 GHz.

Enter 2 for 5 GHz.

Enter 3 for Both.

2. Select Target Network:

Wait for the scan to finish. A table will show available Wi-Fi networks.

Enter the target number (e.g., 1, 2, 3) to lock the target.

3. Select Attack Strategy:

The tool will scan for connected devices.

Enter 1 to attack specific devices (e.g., 1 3).

Enter 2 to attack ALL devices on that network (Broadcast).

4. The Attack Loop:

The script will automatically loop between 20 seconds of Deauth (disconnecting victims) and 20 seconds of Fake AP (hosting the fake Wi-Fi).

🔑 How to Check Captured Passwords
When the victim enters their password on the fake page, it is saved locally.

To view the passwords:
Keep the attack running, open a new terminal window, and type:

bash
cat /var/www/html/creds.txt
You will see the victim's IP, the Router name, and their Password.

⚠️ If the victim doesn't see the page:
Tell them to open their mobile browser and go to http://neverssl.com or http://10.0.0.1 (Must be HTTP, not HTTPS).

🚨 Troubleshooting
Error: Port 80 already in use
If you have Docker running, it might conflict with Apache. Stop Docker first:
sudo systemctl stop docker

No networks found during scan?
Unplug and replug your external Wi-Fi adapter. Ensure it is in Monitor Mode. Check if it is named wlan1.

My adapter is not named wlan1:
Open phantom.sh using nano, and replace all instances of wlan1 with your actual adapter name (e.g., wlan0).
