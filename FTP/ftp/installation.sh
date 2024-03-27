#!/bin/bash

figlet "Installation FTP"|lolcat

# Installation des paquets
apt update -y >/dev/null 2>/dev/null
apt install -y apache2 pure-ftpd >/dev/null 2>/dev/null

# Mise en place apache2
echo "<Directory /home/ftp/>" >> /etc/apache2/apache2.conf
echo "Options Indexes FollowSymLinks" >> /etc/apache2/apache2.conf
echo "AllowOverride None" >> /etc/apache2/apache2.conf
echo "Require all granted" >> /etc/apache2/apache2.conf
echo "</Directory>" >> /etc/apache2/apache2.conf

sed -i 's/\/var\/www\/html/\/home\/ftp/g' /etc/apache2/sites-available/000-default.conf

IP=`ip a | grep enp0s3 | tail -n 1 | tr -s ' ' | cut -d' ' -f3`
IP2="${IP::-3}"

#Création utilisateur virtu
groupadd --gid 6262 ftpGroup
useradd -u 6262 -g ftpGroup -d /dev/null -s /bin/false ftpUser
useradd -m -p btsinfo ftp -s /bin/false
mkdir /home/FTP
ln -s /etc/pure-ftpd/conf/PureDB /etc/pure-ftpd/auth/75puredb
echo no > /etc/pure-ftpd/conf/PAMAuthentication
echo no > /etc/pure-ftpd/conf/UnixAuthentication
echo yes > /etc/pure-ftpd/conf/CreateHomeDir
echo no > /etc/pure-ftpd/conf/NoAnonymous
echo $IP2 > /etc/pure-ftpd/conf/ForcePassiveIP
echo "51100 51300" > /etc/pure-ftpd/conf/PassivePortRange

echo "Choisissez votre nom d'utilisateur :"
read -p "> " user
pure-pw useradd $user -u ftpUser -d  /home/FTP/$user -m
echo ""
echo "Utilisateur créé"

# Redémarrage du serveur pure-ftpd
systemctl restart pure-ftpd.service
systemctl restart apache2
