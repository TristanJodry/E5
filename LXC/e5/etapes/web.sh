#!/bin/bash

#Mise en place de apache et haproxy
#web1
echo -e "\nMise en place de web1"
echo 'Acquire::http::Proxy "http://192.168.11.12:3128";' > /var/lib/lxc/web1/rootfs/etc/apt/apt.conf.d/05Proxy
lxc-attach -n web1 -- apt update > /dev/null 2> /dev/null
lxc-attach -n web1 -- apt install -y apache2 > /dev/null 2> /dev/null
echo "site1" > /var/lib/lxc/web1/rootfs/var/www/html/index.html
lxc-attach -n web1 -- systemctl restart apache2

#web2
echo "Mise en place de web2"
echo 'Acquire::http::Proxy "http://192.168.11.12:3128";' > /var/lib/lxc/web2/rootfs/etc/apt/apt.conf.d/05Proxy
lxc-attach -n web2 -- apt update > /dev/null 2> /dev/null
lxc-attach -n web2 -- apt install -y apache2 > /dev/null 2> /dev/null
echo "site2" > /var/lib/lxc/web2/rootfs/var/www/html/index.html
lxc-attach -n web2 -- systemctl restart apache2

#haproxy
echo "Mise en place de haproxy"
echo 'Acquire::http::Proxy "http://192.168.11.12:3128";' > /var/lib/lxc/haproxy/rootfs/etc/apt/apt.conf.d/05Proxy
lxc-attach -n haproxy -- apt update > /dev/null 2> /dev/null
lxc-attach -n haproxy -- apt install -y haproxy > /dev/null 2> /dev/null
echo -e "frontend proxypublic\n    mode http\n    bind *:80\n    acl regle1 hdr(host) site1.tgplus.net\n    acl regle2 hdr(host) site2.tgplus.net\n\n    use_backend site1 if regle1\n    use_backend site2 if regle2\n\nbackend site1\n    mode http\n    option httpchk\n    server web1 "$ipweb1"\nbackend site2\n    mode http\n    option httpchk\n    server web2 "$ipweb2 > /var/lib/lxc/haproxy/rootfs/etc/haproxy/haproxy.cfg
lxc-attach -n haproxy -- systemctl restart haproxy
