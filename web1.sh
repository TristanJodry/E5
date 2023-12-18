#!/bin/bash 

echo site1 > /var/www/html/index.html
systemctl restart apache2