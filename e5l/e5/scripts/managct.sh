 #!/bin/bash
figlet "MANAGEMENT CT"
quitter=1
nb=0
txt=$(lxc-ls -f | cut -d ' ' -f 1 | tail -n +2 > infoct.txt)
x=$(wc infoct.txt -l | cut -d ' ' -f 1)
while [[ $quitter -ne 0 ]]
do
    echo -e "Menu :\n1- Allumer les conteneurs\n2- Eteindre les contenerus\n3- Etat des conteneurs\n4- Mise en place des conteneurs\n0- Quitter"
    read choix1
    case $choix1 in
	1 )
	$txt
	while [[ nb -lt $x ]]
	do
	let "nb=nb+1"
	ct=$(head -n $nb infoct.txt | tail -n 1)
	lxc-start -n $ct
	done
	nb=0
	;;
	2 )
	$txt
	while [[ nb -lt $x ]]
	do
	let "nb=nb+1"
	ct=$(head -n $nb infoct.txt | tail -n 1)
	lxc-stop -n $ct
	done
	nb=0
	;;
        3 )
	lxc-ls -f
	;;
	4 )
	echo "Configuration de Web1"
	#web1
	lxc-attach -n web1 -- apt install -y apache2 > /dev/null >2 /dev/null
	lxc-attach -n web1 -- echo "site1" > /var/www/html/index.html
	lxc-attach -n web1 -- systemctl restart apache2
	#web2
	lxc-attach -n web2 -- apt install -y apache2 > /dev/null >2 /dev/null
	lxc-attach -n web2 -- echo "site2" > /var/www/html/index.html
	lxc-attach -n web2 -- systemctl restart apache2
	#haproxy
	lxc-attach -n haproxy -- apt install -y haproxy wget > /dev/null >2 /dev/null
	lxc-attach -n haproxy -- wget https://github.com/TristanJodry/E5/raw/main/confhaproxy
	lxc-attach -n haproxy -- echo confhaproxy > /etc/haproxy/haproxy.cfg
	lxc-attach -n haproxy -- systemctl restart haproxy
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
