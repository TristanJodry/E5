 #!/bin/bash
figlet "OPTIONS"
quitter=1
jour=$(date +"_"%Y"_"%m"_"%d)
while [[ $quitter -ne 0 ]]
do
    echo -e "Menu :\n1- Décompression du fichier ubuntu\n2- Envoyer une backup test\n3- Création script backup\n4- Envoi de la clé ssh\n0- Quitter"
    read choix1
    case $choix1 in
	1 )
	if [ -d "/var/cache/lxc/download/" ];then
	echo -e "Le dossier existe déja\n"
	else
	echo "Décompression en cours ..."
	tar -xzf cache/ubuntu16.tar.gz -C /var/cache/lxc/
	echo "Décompression terminée."
	fi
	;;
	2 )
	echo "Veuillez rentrer l'ip de la machine à joindre"
	read ip
	rep=$(ping $ip -c 2 | grep " 0% packet loss" | wc -l)
	if [[ $rep -eq 1 ]]
	then
	echo -e "\nArret des conteneurs\n"
	lxc-stop -n web1
	lxc-stop -n web2
	echo -e "\nCréation des archives\n"
	cd backups/
	tar -czf BackupWEB1$jour.tar.gz /var/lib/lxc/web1/
	tar -czf BackupWEB2$jour.tar.gz /var/lib/lxc/web2/
	cd ../
	echo -e "\nRedémarrage des conteneurs\n"
	lxc-start -n web1
	lxc-start -n web2
	echo -e "\n1- Envoi par mdp\n2- Envoi avec clé ssh"
	read choix2
	case $choix2 in
	1 )
	echo -e "\nEnvoie des backups vers "$ip"\n"
	scp ~/e5/backups/* root@$ip:/backupsWEB/
	rm backups/*
	;;
	2)
	echo "Indiquer le  le chemin de la clé ssh"
	echo '"/root/.ssh/id_rsa"'
	read dos2
	echo -e "\nEnvoie des backups vers "$ip"\n"
	scp -i $dos2 ~/e5/backups/* root@$ip:/backupsWEB/
	rm backups/*
	;;
	* )
	echo "Erreur de saisie"
	;;
	esac
	else
	echo -e "\nLa machine $ip ne répond pas\n"
	fi
	;;
        3 )
	echo "le dossier backupsWEB sur la machine backup est-il créé?(o/n)"
	read choix3
  	 case $choix3 in
	 o )
 	 echo "Création du script..."
	 echo -e "#!/bin/bash\n\njour=\$(date +"_"%Y"_"%m"_"%d)\ntar -czf BackupWEB1\$jour.tar.gz /var/lib/lxc/web1/\ntar -czf BackupWEB2\$jour.tar.gz /var/lib/lxc/web1/\nscp -i /root/.ssh/id_rsa ~/e5/backups/* root@192.168.34.101:/backupsWEB/\nrm backups/*" > /etc/cron.daily/backup.sh
	 echo "Mise en place de la tâche cron"
	 chmod +x /etc/cron.daily/backup.sh
	 ;;
	 n )
	 echo "Veuillez créé le dossier sur la machine backup"
	 ;;
	 * )
	 echo "Erreur"
	 ;;
	 esac
	;;
	4)
	echo "Ip de la machine à joindre"
	read ip2
	echo "Création des clés ssh"
	ssh-keygen -t rsa -b 2048
	echo "Envoi de la clé publique à "$ip2""
	ssh-copy-id root@$ip2 
	chmod 0400 /root/.ssh/id_rsa.pub
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
