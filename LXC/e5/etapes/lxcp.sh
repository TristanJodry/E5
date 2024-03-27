#!/bin/bash

#Fichier lxc-net
echo -e 'USE_LXC_BRIDGE="true"\nLXC_ADDR="192.168.100.254"\nLXC_NETWORK="192.168.100.0/24"\nLXC_DHCP_RANGE="192.168.100.1,192.168.100.10"' >/etc/default/lxc-net

#Fichier default.conf
echo -e 'lxc.net.0.type = veth\nlxc.net.0.link = lxcbr0\nlxc.net.0.flags = up\nlxc.net.0.hwaddr = 00:16:3e:xx:xx:xx\nlxc.start.auto = 1' >/etc/lxc/default.conf
systemctl restart lxc-net