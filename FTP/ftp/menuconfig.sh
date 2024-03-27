#!/bin/bash

quitter=1

figlet "FTP"|lolcat
while [[ $quitter -ne 0 ]]
do
echo ""
echo "1) Autoriser/Interdire le renommage de fichiers/dossiers"
echo "2) Autoriser/Interdire le téléchargement de fichiers pour les Anonymes"
echo "3) Autoriser/Interdire la création de dossiers pour les Anonymes"
echo "4) Activer/Désactiver un quota"
echo "5) Download/Upload"
echo "0) Retour au menu principal"
echo -e "Veuillez choisir une option :"
read choix
case $choix in 
	1 )
		bash renom.sh
		;;
	2 )
		bash anodownload.sh
		;;
	0 )
		quitter=0
		;;
	3 )
		bash anocantcreate.sh
		;;
	4 )
		bash quota.sh
		;;
	5 )
		bash UserBandwidth.sh
		;;
	* )
		echo "Erreur dans la saisie"
		;;
esac
done
