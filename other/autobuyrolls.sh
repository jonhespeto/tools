#!/bin/bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && {
  echo -e "Only root user may run the script!"
  exit 1
}

if [ ! -z "${SUDO_USER:-}" ]; then
  directory=/home/"$SUDO_USER"
else
  directory="$HOME"
fi

tee "$directory"/rollsup.sh > /dev/null <<EOF
#!/bin/sh
#Версия 0.15
cd $directory/massa/massa-client
#Set variables
catt=/usr/bin/cat
passwd=\$(\$catt $directory/mspasswd)
candidat=\$(./massa-client wallet_info -p "\$passwd"|grep 'Rolls'|awk '{print \$4}'| sed 's/=/ /'|awk '{print \$2}')
massa_wallet_address=\$(./massa-client -p "\$passwd" wallet_info |grep 'Address'|awk '{print \$2}')
tmp_final_balans=\$(./massa-client -p "\$passwd" wallet_info |grep 'Balance'|awk '{print \$3}'| sed 's/=/ /'|sed 's/,/ /'|awk '{print \$2}')
final_balans=\${tmp_final_balans%%.*}
averagetmp=\$(\$catt /proc/loadavg | awk '{print \$1}')
node=\$(./massa-client -p "\$passwd" get_status |grep 'Error'|awk '{print \$1}')
if [ -z "\$node" ]&&[ -z "\$candidat" ];then
echo \`/bin/date +"%b %d %H:%M"\` "(rollsup) Node is currently offline" >> $directory/rolls.log
elif [ \$candidat -gt "0" ];then
echo "Ok" > /dev/null
elif [ \$final_balans -gt "99" ]; then
echo \`/bin/date +"%b %d %H:%M"\` "(rollsup) The roll flew off, we check the number of coins and try to buy" >> $directory/rolls.log
resp=\$(./massa-client -p "\$passwd" buy_rolls \$massa_wallet_address 1 0)
else
echo \`/bin/date +"%b %d %H:%M"\` "(rollsup) Not enough coins to buy a roll from you \$final_balans, minimum 100" >> $directory/rolls.log
fi
EOF

printf "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin\n*/3 * * * * root /bin/bash %s/rollsup.sh > /dev/null 2>&1\n" "$directory" > /etc/cron.d/massarolls

read -r -s -p "Enter password : " pass
echo ""
tee "$directory"/mspasswd > /dev/null <<EOF
$pass
EOF

tee "$directory"/rolls.log > /dev/null <<EOF
Лог файл создан удачно.
EOF
