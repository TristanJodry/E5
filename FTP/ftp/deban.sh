#!/bin/bash

figlet "FTP"|lolcat

echo "Quel adresse IP voulez-vous débannir ? :"
iptables -L INPUT --line-numbers

read -p "> " num

iptables -D INPUT $num

echo ""
echo "Adresse IP débannie !"

echo ""
echo "[Appuyer sur entrer pour continuer]"
read
