#!/bin/bash

quitter=1

source /root/ftp/fonction.sh

figlet "FTP"|lolcat

while [[ $quitter -ne 0 ]]
do
echo "Quel adresse IP voulez-vous bannir ? :"
read -p "> " ip
estUneIP $ip
done

iptables -A INPUT -s $ip -j DROP >/dev/null 2>/dev/null

echo ""
echo "Adresse IP bannie !"

echo ""
echo "[Appuyer sur entrer pour continuer]"
read
