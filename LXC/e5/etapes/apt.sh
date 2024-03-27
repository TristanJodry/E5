#!/bin/bash

#Installation des paquets
echo -e "\nInstallation des paquets..."
apt update > /dev/null 2> /dev/null
apt install -y openssh-client lxc > /dev/null 2> /dev/null
apt install -y iptables-persistent
echo "Installation terminée."