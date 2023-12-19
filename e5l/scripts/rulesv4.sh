#!/bin/bash
figlet "IPTABLES"
quitter=1
while [[ $quitter -ne 0 ]]
do
echo -e "Menu :\n1- Reset rules.v4\n2- Règle SNAT\n3- Règle DNAT\n4- Afficher rules.v4\n0- Quitter"
read choix1
case $choix1 in
	1 )
	echo -e "Êtes vous sur de vouloir réinitialiser rules.v4 (o/n)?"
	read reset
	if [[ $reset == 'o' ]]
	then
	echo 'Reset du fichier rules.v4'
	echo -e "#NAT\n*nat\n:PREROUTING ACCEPT [0:0]\n:INPUT ACCEPT [0:0]\n:OUTPUT ACCEPT [0:0]\n:POSTROUTING ACCEPT [0:0]\n\n#SNAT\n\n#DNAT\n\nCOMMIT\n\n*filter\n:INPUT ACCEPT [0:0]\n:OUTPUT ACCEPT [0:0]\n:FORWARD ACCEPT [0:0]\n\nCOMMIT" > /etc/iptables/rules.v4
	cat /etc/iptables/rules.v4
	elif [[ $reset == 'n' ]]
	then
	echo 'Retour'
	else
	echo 'Erreur'
	fi
	;;
	2 )
	echo -e  "Création d'une règle de SNAT\nQuelle est votre interface réseau ?\nListe des interfaces réseaux :"
	ls /sys/class/net
	read int
	ipa=$(ip a | grep $int | grep 'inet ' | cut -d ' ' -f 6 | cut -d '/' -f 1)
	echo 'Votre ip est bien '$ipa' ? (o/n)'
	read rep
	if [[ $rep == 'o' ]]
	then
	sed -i 's/#SNAT/#SNAT\n-A POSTROUTING -s '$ipa' ! -d '$ipa' -j MASQUERADE/g' /etc/iptables/rules.v4
	cat /etc/iptables/rules.v4
	elif [[ $rep == 'n' ]]
	then
	echo 'Quelle est votre ip ?'
	read ipa
	sed -i 's/#SNAT/#SNAT\n-A POSTROUTING -s '$ipa' ! -d '$ipa' -j MASQUERADE/g' /etc/iptables/rules.v4
	else
	echo 'Erreur de saisie'
	fi
	;;
	3 )
	echo -e 'Création du règle de DNAT\nCarte réseau ?'
	ls /sys/class/net
	read cr
	echo 'Protocol utilisé ?(Exemple :tcp,udp,icmp)'
	read prot
	echo 'Ip destination ?'
	read ipd
	echo 'Port destination ?'
	read pd
	echo '-A PREROUTING -i '$cr' -p '$prot' --dport '$pd' -j DNAT --to-destination '$ipd'' 
	;;
	4 )
	cat /etc/iptables/rules.v4
	;;
	0 )
	quitter=0
	figlet "Retour"
	exit
	;;
	* )
	echo "Erreur de saisie"
	;;
esac
done
