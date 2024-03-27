#!/bin/bash

figlet "UserBandwidth" |lolcat

echo "Quelle limite pour le download voulez-vous mettre ? :"
read down
echo "Quelle limite pour l'upload voulez-vous mettre ? :"
read upl
echo "$down:$upl" > /etc/pure-ftpd/conf/UserBandwidth

systemctl restart pure-ftpd
