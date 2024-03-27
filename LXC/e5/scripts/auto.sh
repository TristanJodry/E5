
#!/bin/bash

#Vérification
echo -e "\nAvez-vous créé le dossier backupsWEB sur la machine backup? (o/n)"
read rep1
echo -e "\nAvez-vous permis la connexion root sur la machine backup? (o/n)"
read rep2

if [[ $rep1 && $rep2 == o ]]
then
#Installation des paquets
echo -e "\nInstallation des paquets..."
apt update > /dev/null 2> /dev/null
apt install -y openssh-client lxc > /dev/null 2> /dev/null
apt install -y iptables-persistent
echo "Installation terminée."

#LXC
#Décompression de ubuntu16
echo -e "\nDécompression du cache ubuntu16"
tar -xvf cache/ubuntu16.tar.gz -C /var/cache/lxc/

#Fichier lxc-net
echo -e 'USE_LXC_BRIDGE="true"\nLXC_ADDR="192.168.100.254"\nLXC_NETWORK="192.168.100.0/24"\nLXC_DHCP_RANGE="192.168.100.1,192.168.100.10"' >/etc/default/lxc-net

#Fichier default.conf
echo -e 'lxc.net.0.type = veth\nlxc.net.0.link = lxcbr0\nlxc.net.0.flags = up\nlxc.net.0.hwaddr = 00:16:3e:xx:xx:xx\nlxc.start.auto = 1' >/etc/lxc/default.conf
systemctl restart lxc-net

#Création des conteneurs
echo -e "\nCréation des conteneurs"
echo -e "\nCréation de web1"
DOWNLOAD_KEYSERVER="keyserver.ubuntu.com" lxc-create -t download -n web1 -- -d ubuntu -r xenial -a amd64
echo -e "\nCréation de web2"
DOWNLOAD_KEYSERVER="keyserver.ubuntu.com" lxc-create -t download -n web2 -- -d ubuntu -r xenial -a amd64
echo -e "\nCréation de haproxy"
DOWNLOAD_KEYSERVER="keyserver.ubuntu.com" lxc-create -t download -n haproxy -- -d ubuntu -r xenial -a amd64
ipweb1=$(lxc-ls -f web1 | tail -n 1 | cut -d ' ' -f 18)
ipweb2=$(lxc-ls -f web2 | tail -n 1 | cut -d ' ' -f 18)
iphaproxy=$(lxc-ls -f haproxy | tail -n 1 | cut -d ' ' -f 18)
lxc-start web1
lxc-start web2
lxc-start haproxy
while [[ $ipweb1 == "-" || $ipweb2 == "-" || $iphaproxy == "-" ]]
do
ipweb1=$(lxc-ls -f web1 | tail -n 1 | cut -d ' ' -f 18)
ipweb2=$(lxc-ls -f web2 | tail -n 1 | cut -d ' ' -f 18)
iphaproxy=$(lxc-ls -f haproxy | tail -n 1 | cut -d ' ' -f 18)
sleep 1
done
lxc-ls -f

#Mise en place de apache et haproxy
#web1
echo -e "\nMise en place de web1"
echo 'Acquire::http::Proxy "http://192.168.11.12:3128";' > /var/lib/lxc/web1/rootfs/etc/apt/apt.conf.d/05Proxy
lxc-attach -n web1 -- apt update > /dev/null 2> /dev/null
lxc-attach -n web1 -- apt install -y apache2 > /dev/null 2> /dev/null
echo "site1" > /var/lib/lxc/web1/rootfs/var/www/html/index.html
lxc-attach -n web1 -- systemctl restart apache2

#web2
echo "Mise en place de web2"
echo 'Acquire::http::Proxy "http://192.168.11.12:3128";' > /var/lib/lxc/web2/rootfs/etc/apt/apt.conf.d/05Proxy
lxc-attach -n web2 -- apt update > /dev/null 2> /dev/null
lxc-attach -n web2 -- apt install -y apache2 > /dev/null 2> /dev/null
echo "site2" > /var/lib/lxc/web2/rootfs/var/www/html/index.html
lxc-attach -n web2 -- systemctl restart apache2

#haproxy
echo "Mise en place de haproxy"
echo 'Acquire::http::Proxy "http://192.168.11.12:3128";' > /var/lib/lxc/haproxy/rootfs/etc/apt/apt.conf.d/05Proxy
lxc-attach -n haproxy -- apt update > /dev/null 2> /dev/null
lxc-attach -n haproxy -- apt install -y haproxy > /dev/null 2> /dev/null
echo -e "frontend proxypublic\n    mode http\n    bind *:80\n    acl regle1 hdr(host) site1.tgplus.net\n    acl regle2 hdr(host) site2.tgplus.net\n\n    use_backend site1 if regle1\n    use_backend site2 if regle2\n\nbackend site1\n    mode http\n    option httpchk\n    server web1 "$ipweb1"\nbackend site2\n    mode http\n    option httpchk\n    server web2 "$ipweb2 > /var/lib/lxc/haproxy/rootfs/etc/haproxy/haproxy.cfg
lxc-attach -n haproxy -- systemctl restart haproxy

#Iptables
echo "Création de règles iptables"
carte=$(ls /sys/class/net | cut -d ' ' -f 1 | head -n 1)
echo -e "#NAT\n*nat\n:PREROUTING ACCEPT [0:0]\n:INPUT ACCEPT [0:0]\n:OUTPUT ACCEPT [0:0]\n:POSTROUTING ACCEPT [0:0]\n\n#SNAT\n-A POSTROUTING -s 192.168.100.0/24 ! -d 192.168.100.0/24 -j MASQUERADE\n#DNAT\n-A PREROUTING -i $carte -p tcp --dport 80 -j DNAT --to-destination $iphaproxy:80\nCOMMIT\n\n*filter\n:INPUT ACCEPT [0:0]\n:OUTPUT ACCEPT [0:0]\n:FORWARD ACCEPT [0:0]\n\nCOMMIT" > /etc/iptables/rules.v4
systemctl restart netfilter-persistent

#Script Backup
echo "Ecriture du scipt de backup"
echo -e "#!/bin/bash\n\njour=\$(date +"_"%Y"_"%m"_"%d)\ntar -czf BackupWEB1\$jour.tar.gz /var/lib/lxc/web1/\ntar -czf BackupWEB2\$jour.tar.gz /var/lib/lxc/web1/\nscp -i /root/.ssh/id_rsa ~/e5/backups/* root@192.168.34.101:/backupsWEB/\nrm backups/*" > /etc/cron.daily/backup.sh

#Ssh
echo "Création de la clef ssh"
ssh-keygen -t rsa -b 2048
ssh-copy-id root@192.168.34.101
chmod 0400 /root/.ssh/id_rsa.pub

echo "Script terminé."
else
echo "Effectuez d'abord les réglages nécessaires"
fi
