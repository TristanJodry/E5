#!/bin/bash

source /root/ftp/config.sh >/dev/null 2>/dev/null

if [[ $conf -eq 0 ]];then
	echo "Installation des paquets nécessaires ..."
	apt update >/dev/null 2>/dev/null
	apt install lolcat figlet -y >/dev/null 2>/dev/null
	gem install lolcat >/dev/null 2>/dev/null
	echo "#!/bin/bash" > /root/ftp/config.sh
	echo "conf=1" >> /root/ftp/config.sh
fi

echo ""

echo "Bienvenue dans :"
figlet "FTP"|lolcat
quitter=1
while [[ $quitter -ne 0 ]]
do
echo ""
echo "1) Installation de FTP"
echo "2) Création d'un utilisateur"
echo "3) Bannir une adresse IP"
echo "4) Débannir une adresse IP"
echo "5) Mettre en place le service ssh"
echo "6) Fichiers de configuration de FTP"
echo "7) Mise en place TLS"
echo "0) Quitter"
echo -e "Veuillez choisir une option :"
read choix
case $choix in
	1 )
		bash installation.sh
		;;
	2 )
		bash user.sh
		;;
	0 )
		quitter=0
		figlet "Au revoir"|lolcat
		;;
	3 )
		bash ban.sh
		;;
	4 )
		bash deban.sh
		;;
	5 )
		bash ssh.sh
		;;
	6 )
		bash menuconfig.sh
		;;
	7)
		bash tls.sh
		;;
	* )
		echo "Erreur dans la saisie"
		;;
esac
done
