#!/bin/bash

figlet "Utilisateur"|lolcat

echo "Choisissez votre nom d'utilisateur :"
read -p "> " user
pure-pw useradd $user -u ftpUser -d  /home/FTP/$user -m
echo ""
echo "Utilisateur créé"

echo ""
echo "[Appuyer sur entrer pour continuer]"
read 
