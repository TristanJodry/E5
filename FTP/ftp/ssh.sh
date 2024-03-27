#!/bin/bash
figlet FTP|lolcat
echo ""
echo "Mise en place de la connexion ssh ..."
apt update >/dev/null 2>/dev/null
apt install openssh-server -y >/dev/null 2>/dev/null

sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

IP=`ip a | grep enp0s3 | tail -n 1 | tr -s ' ' | cut -d' ' -f3`
IP2="${IP::-3}"

service ssh restart
echo ""
echo "Connexion ssh en tant que root établie"
echo ""
echo "Votre adresse IP : $IP2"

echo ""
echo "[Appuyer sur entrer pour continuer]"
read
