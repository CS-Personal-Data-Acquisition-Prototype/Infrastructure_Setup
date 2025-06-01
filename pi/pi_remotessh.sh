#!/bin/bash
echo -n "Enter server SSH private key path > "
read keypath
sed -i "s/<path>/$keypath/g" remotessh.service
echo -n "Enter server SSH username > "
read username
sed -i "s/<user>/$username/g" remotessh.service
mv remotessh.service /etc/systemd/system/
systemctl enable remotessh
systemctl start remotessh
echo "Remote SSH enabled. Connect to localhost port 2222 on remote server."