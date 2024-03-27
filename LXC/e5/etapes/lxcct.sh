#!/bin/bash

#Création des conteneurs
echo -e "\nCréation des conteneurs"
echo -e "\nCréation de web1"
DOWNLOAD_KEYSERVER="keyserver.ubuntu.com" lxc-create -t download -n web1 -- -d ubuntu -r xenial -a amd64
echo -e "\nCréation de web2"
DOWNLOAD_KEYSERVER="keyserver.ubuntu.com" lxc-create -t download -n web2 -- -d ubuntu -r xenial -a amd64
echo -e "\nCréation de haproxy"
DOWNLOAD_KEYSERVER="keyserver.ubuntu.com" lxc-create -t download -n haproxy -- -d ubuntu -r xenial -a amd64
ipweb1=$(lxc-ls -f web1 | tail -n 1 | cut -d ' ' -f 18)
ipweb2=$(lxc-ls -f web2 | tail -n 1 | cut -d ' ' -f 18)
iphaproxy=$(lxc-ls -f haproxy | tail -n 1 | cut -d ' ' -f 18)
lxc-start web1
lxc-start web2
lxc-start haproxy
while [[ $ipweb1 == "-" || $ipweb2 == "-" || $iphaproxy == "-" ]]
do
ipweb1=$(lxc-ls -f web1 | tail -n 1 | cut -d ' ' -f 18)
ipweb2=$(lxc-ls -f web2 | tail -n 1 | cut -d ' ' -f 18)
iphaproxy=$(lxc-ls -f haproxy | tail -n 1 | cut -d ' ' -f 18)
sleep 1
done
lxc-ls -f