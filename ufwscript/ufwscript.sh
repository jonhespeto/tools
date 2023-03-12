#!/bin/bash
set -euo pipefail
# Checking to run the script as root
[ "$(id -u)" -ne 0 ] && { echo "Only root user may run the script!"; exit 1; }
# Entering the domain at the first startup
if [ ! -f ~/domain.txt ]; then
    read -r -p "Enter domain : " domain
    echo "$domain" > ~/domain.txt
fi
# Path to script
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
# Cron job
job="* * * * * $SCRIPT_DIR/ufwscript.sh"
# Check the status of ufw if the status is not active run
if ! sudo ufw status | grep -q "Status: active"; then
   yes | sudo ufw --force enable || true
fi
# Get the ip address of the domain
IP=$(nslookup "$(cat ~/domain.txt)" | awk '/^Address: / { print $2 }')

# Check the existence of file lastip.txt , if not, then create and add the rule in ufw
if [ ! -f ~/lastip.txt ]; then
   echo "$IP" > ~/lastip.txt
   sudo ufw allow from "$IP" to any
#Added a notification to Telegram.
   curl -s "https://api.telegram.org/botXXXXXXXXX:XXXXXXXXXXXXXXXXXXXXXXXX__XXXXXXXXX/sendMessage?chat_id=XXXXXXXX=&parse_mode=html&text=<b>IP address changed. New ip adress $IP. UFW rule added</b>"
fi
# Checking the existence of the task in the cron
if crontab -u root -l 2>/dev/null | grep -q "$job"; then
   :
else
   (crontab -u root -l 2>/dev/null; echo "$job") | crontab -u root -
fi
# Check if the ip address has changed delete old rule and add new 
if [ "$IP" = "$(cat ~/lastip.txt)" ]; then
   exit 0
 else
   if sudo ufw status numbered | grep -q "$(cat ~/lastip.txt)"; then
      sudo ufw delete allow from "$(cat ~/lastip.txt)"
   fi
   echo "$IP" > ~/lastip.txt
   sudo ufw allow from "$IP" to any
#Added a notification to Telegram.
   curl -s "https://api.telegram.org/botXXXXXXXXX:XXXXXXXXXXXXXXXXXXXXXXXX__XXXXXXXXX/sendMessage?chat_id=XXXXXXXX=&parse_mode=html&text=<b>IP address changed. New ip adress $IP. UFW rule added</b>"
fi
