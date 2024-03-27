#!/bin/bash

figlet "Quota" |lolcat

echo "Quelle quota voulez-vous mettre ? :"
read quota

echo "$quota" > /etc/pure-ftpd/conf/MaxDiskUsage

systemctl restart pure-ftpd
