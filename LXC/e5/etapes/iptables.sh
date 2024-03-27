#!/bin/bash

#Iptables
echo "Création de règles iptables"
carte=$(ls /sys/class/net | cut -d ' ' -f 1 | head -n 1)
echo -e "#NAT\n*nat\n:PREROUTING ACCEPT [0:0]\n:INPUT ACCEPT [0:0]\n:OUTPUT ACCEPT [0:0]\n:POSTROUTING ACCEPT [0:0]\n\n#SNAT\n-A POSTROUTING -s 192.168.100.0/24 ! -d 192.168.100.0/24 -j MASQUERADE\n#DNAT\n-A PREROUTING -i $carte -p tcp --dport 80 -j DNAT --to-destination $iphaproxy:80\nCOMMIT\n\n*filter\n:INPUT ACCEPT [0:0]\n:OUTPUT ACCEPT [0:0]\n:FORWARD ACCEPT [0:0]\n\nCOMMIT" > /etc/iptables/rules.v4
systemctl restart netfilter-persistent