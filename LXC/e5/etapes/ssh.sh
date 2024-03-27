#!/bin/bash

#Ssh
echo "Création de la clef ssh"
ssh-keygen -t rsa -b 2048
ssh-copy-id root@192.168.34.101
chmod 0400 /root/.ssh/id_rsa.pub