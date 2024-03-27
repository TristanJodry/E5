#!/bin/bash

figlet "FTP"|lolcat

quitter=1
while [[ $quitter -ne 0 ]]
do
echo "1) Autoriser le renommage de fichiers/dossiers"
echo "2) Interdire le renommage de fichiers/dossiers"
echo "0) Retour"
echo -e "Veuillez choisir une option :"
read choix
case $choix in
	1 )
		echo "no" > /etc/pure-ftpd/conf/AutoRename
		;;
	2 )
		echo "yes" > /etc/pure-ftpd/conf/AutoRename
		;;
	0 )
		quitter=0
		;;
	* )
		echo "Erreur dans la saisie"
		;;
esac
done
