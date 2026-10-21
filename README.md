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
git clone https://github.com/hossain242-35-397-dev/X-MAP-Auto-Phantom.git
cd X-MAP-Auto-Phantom
