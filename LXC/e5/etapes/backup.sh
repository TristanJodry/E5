#!/bin/bash

#Script Backup
echo "Ecriture du scipt de backup"
echo -e "#!/bin/bash\n\njour=\$(date +"_"%Y"_"%m"_"%d)\ntar -czf BackupWEB1\$jour.tar.gz /var/lib/lxc/web1/\ntar -czf BackupWEB2\$jour.tar.gz /var/lib/lxc/web1/\nscp -i /root/.ssh/id_rsa ~/e5/backups/* root@192.168.34.101:/backupsWEB/\nrm backups/*" > /etc/cron.daily/backup.sh
