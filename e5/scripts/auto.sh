#!/bin/bash

#Vérification
echo "Avez-vous créé le dossier backupsWEB sur la machine backup? (o/n)"
read rep1
echo "Avez-vous permis la connexion root sur la machine backup? (o/n)"
read rep2


#Installation des paquets
echo "Installation des paquets..."
apt update > /dev/null 2> /dev/null
apt install -y openssh-client lxc > /dev/null 2> /dev/null
apt install -y iptables-persistent
echo "Installation terminée"

#LXC
#Décompression de ubuntu16
tar -xzf cache/ubuntu16.tar.gz -C /var/cache/lxc/
#Fichier lxc-net
	echo -e 'USE_LXC_BRIDGE="true"\nLXC_ADDR="192.168.100.254"\nLXC_NETWORK="192.168.100.0/24"\nLXC_DHCP_RANGE="192.168.100.1,192.168.100.10"' >/etc/default/lxc-net
#Fichier default.conf
	echo -e 'lxc.net.0.type = veth\nlxc.net.0.link = lxcbr0\nlxc.net.0.flags = up\nlxc.net.0.hwaddr = 00:16:3e:xx:xx:xx\nlxc.start.auto = 1' >/etc/lxc/default.conf
	systemctl restart lxc-net
#Création des conteneurs
DOWNLOAD_KEYSERVER="keyserver.ubuntu.com" lxc-create -t download -n web1 -- -d ubuntu -r xenial -a amd64
DOWNLOAD_KEYSERVER="keyserver.ubuntu.com" lxc-create -t download -n web2 -- -d ubuntu -r xenial -a amd64
DOWNLOAD_KEYSERVER="keyserver.ubuntu.com" lxc-create -t download -n haproxy -- -d ubuntu -r xenial -a amd64
lxc-start web1
lxc-start web2
lxc-start haproxy
sleep 3
lxc-ls -f
sleep 3
#Mise en place de apache et haproxy
#web1
lxc-attach -n web1 -- apt update > /dev/null 2> /dev/null
lxc-attach -n web1 -- apt install -y apache2 wget > /dev/null 2> /dev/null
lxc-attach -n web1 -- wget https://github.com/TristanJodry/E5/raw/main/web1.sh
lxc-attach -n web1 -- chmod +x web1.sh
lxc-attach -n web1 -- ./web1.sh
#web2
lxc-attach -n web2 -- apt update > /dev/null 2> /dev/null
lxc-attach -n web2 -- apt install -y apache2 wget > /dev/null 2> /dev/null
lxc-attach -n web2 -- wget https://github.com/TristanJodry/E5/raw/main/web2.sh
lxc-attach -n web2 -- chmod +x web2.sh
lxc-attach -n web2 -- ./web2.sh

#haproxy
#!!trouver solution ip ct!!
lxc-attach -n haproxy -- apt update > /dev/null 2> /dev/null
lxc-attach -n haproxy -- apt install -y haproxy wget nano > /dev/null 2> /dev/null
lxc-attach -n haproxy -- wget https://github.com/TristanJodry/E5/raw/main/haproxy.sh
lxc-attach -n haproxy -- chmod +x haproxy.sh
lxc-attach -n haproxy -- ./haproxy.sh

#Iptables
iphaproxy=$(lxc-ls -f haproxy | tail -n 1 | cut -d ' ' -f 18)
carte=$(ls /sys/class/net | cut -d ' ' -f 1 | head -n 1)
echo -e "#NAT\n*nat\n:PREROUTING ACCEPT [0:0]\n:INPUT ACCEPT [0:0]\n:OUTPUT ACCEPT [0:0]\n:POSTROUTING ACCEPT [0:0]\n\n#SNAT\n-A POSTROUTING -s 192.168.100.0/24 ! -d 192.168.100.0/24 -j MASQUERADE\n-A PREROUTING -i\n#DNAT\n-A PREROUTING -i $carte -p tcp --dport 80 -j DNAT --to-destination $iphaproxy:80\nCOMMIT\n\n*filter\n:INPUT ACCEPT [0:0]\n:OUTPUT ACCEPT [0:0]\n:FORWARD ACCEPT [0:0]\n\nCOMMIT" > /etc/iptables/rules.v4
systemctl restart netfilter-persistent

#Script Backup
echo -e "#!/bin/bash\n\njour=\$(date +"_"%Y"_"%m"_"%d)\ntar -czf BackupWEB1\$jour.tar.gz /var/lib/lxc/web1/\ntar -czf BackupWEB2\$jour.tar.gz /var/lib/lxc/web1/\nscp -i /root/.ssh/id_rsa ~/e5/backups/* root@192.168.34.101:/backupsWEB/\nrm backups/*" > /etc/cron.daily/backup.sh

#Ssh
echo "Création de la clef ssh"
ssh-keygen -t rsa -b 2048
ssh-copy-id root@192.168.34.101
chmod 0400 /root/.ssh/id_rsa.pub

echo "Script terminé."
