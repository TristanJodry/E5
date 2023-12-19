 #!/bin/bash

quitter=1
chmod -R +x ../e5/
chmod -R +x e5/
cd e5/
figlet "Menu E5"
while [[ $quitter -ne 0 ]]
do
    echo -e "Menu :\n1- Installation des paquets\n2- LXC\n3- IPTABLES\n4- Management de conteneur\n5- Options\n6- Automatique\n0- Quitter"
    read choix1
    case $choix1 in
	1 )
#Installation
	echo "Installation en cours ..."
	apt update > /dev/null 2> /dev/null
	apt install lxc openssh-client figlet -y > /dev/null 2> /dev/null
	apt install iptables-persistent
	echo "Installation terminée."
	;;
	2 )
	./scripts/ct.sh
	;;
        3 )
	./scripts/rulesv4.sh
	;;
	4 )
	./scripts/managct.sh
	;;
	5 )
	./scripts/options.sh
	;;
	6 )
	echo "Voulez vous tout automatiser? Cela peut prendre plusieurs minutes (o/n)"
	read choix2
	case $choix2 in
	o )
	./scripts/auto.sh
	;;
	n )
	;;
	* )
	;;
	esac
	;;
	0 )
	figlet "Aurevoir"
	quitter=0
	;;
	* )
	echo "Erreur dans la saisie"
	;;
	esac
done
