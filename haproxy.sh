#!/bin/bash

echo -e "frontend proxypublic\n    mode http\n    bind *:80\n    acl regle1 hdr(host) site1.tgplus.net\n    acl regle2 hdr(host) site2.tgplus.net\n\n    use_backend site1 if regle1\n    use_backend site2 if regle2\n\nbackend site1\n    mode http\n    option httpchk\n    server web1 192.168.100.4\nbackend site2\n    mode http\n    option httpchk\n    server web2 192.168.100.5" > /etc/haproxy/haproxy.cfg
systemctl restart haproxy
