 #!/bin/bash
figlet "LXC"
quitter=1
retour=0
while [[ $quitter -ne 0 ]]
do
    echo -e "Menu :\n1- Installation des paquets\n2- Création des fichiers de configuration\n3- Création de conteneur\n0- Quitter"
    read choix1
    case $choix1 in
	1 )
#Installation
	apt update
	apt install lxc -y > /dev/null 2> /dev/null
	echo "Installation en cours ..."
	;;
	2 )
#Fichier lxc-net
	echo -e 'USE_LXC_BRIDGE="true"\nLXC_ADDR="192.168.100.254"\nLXC_NETWORK="192.168.100.0/24"\nLXC_DHCP_RANGE="192.168.100.1,192.168.100.10"' >/etc/default/lxc-net
#Fichier default.conf
	echo -e 'lxc.net.0.type = veth\nlxc.net.0.link = lxcbr0\nlxc.net.0.flags = up\nlxc.net.0.hwaddr = 00:16:3e:xx:xx:xx\nlxc.start.auto = 1' >/etc/lxc/default.conf
	systemctl restart lxc-net
	;;
        3 )
#Création de conteneur
	echo -e "Quelle OS voulez-vous installer ?\n1- Ubuntu\n2- Debian"
	read choix2
        case $choix2 in
		1 )
		os='ubuntu'
		;;
		2 )
		os='debian'
		;;
		* )
		echo "Erreur dans la saisie"
		;;
	    esac
	    if [[ $os == 'ubuntu' ]]
	    then
		echo -e "Quelle version de Ubuntu voulez-vous ?\n1- Ubuntu 16\n2- Ubuntu 18\n3- Ubuntu 20\n4- Ubuntu 22\n5- Retour"
		read choix3
		case $choix3 in
		    1 )
		    version='xenial'
		    ;;
		    2 )
		    version='bionic'
		    ;;
		    3 )
		    version='focal'
		    ;;
		    4 )
		    version='jammy'
		    ;;
		    5 )
		    retour=1
		    ;;
		    * )
		    echo "Erreur dans la saisie"
		    ;;
		esac
	    else
		echo -e "Quelle version de Debian voulez-vous ?\n1- Debian 10\n2- Debian 11\n3- Debian 12\n4- Retour"
		read choix4
		case $choix4 in
		    1 )
		    version='buster'
		    ;;
		    2 )
		    version='bullseye'
		    ;;
		    3 )
		    version='bookworm'
		    ;;
		    4 )
		    retour=1
		    ;;
		    * )
		    echo "Erreur dans la saisie"
		    ;;
		esac
	    fi
	    echo "Quelle nom voulez-vous donner a votre conteneur ?"
	    read nom
	    DOWNLOAD_KEYSERVER="keyserver.ubuntu.com" lxc-create -t download -n $nom -- -d $os -r $version -a amd64
	    ;;
	    0 )
	   figlet "Retour"
		quitter=0
	    ;;
	    * )
	    echo "Erreur dans la saisie"
	    ;;
	esac
done
