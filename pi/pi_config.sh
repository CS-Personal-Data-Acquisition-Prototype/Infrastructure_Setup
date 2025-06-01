#!/bin/bash
# Install dependencies
apt-get update
apt-get full-upgrade -y
apt-get install -y git
curl https://sh.rustup.rs -sSf | sh -s -- -y
# create folders
umask 0000
rm -rf /data-acq/
mkdir -m 777 /data-acq/
cd /data-acq/
# download repos
wget https://github.com/CS-Personal-Data-Acquisition-Prototype/ECE_Consolidation/raw/refs/heads/main/dbScript_schema.py
git clone https://github.com/CS-Personal-Data-Acquisition-Prototype/Pi_Transmit
cd Pi_Transmit/
echo -n "Enter server IP address > "
read $ip
wget https://github.com/CS-Personal-Data-Acquisition-Prototype/Infrastructure_Setup/raw/refs/heads/main/pi/rtcp_sconfig.ini
sed -i "s/<ipaddr>/$ip/g" rtcp_sconfig.ini
mv rtcp_sconfig.ini config.ini
cargo build --release
chmod -R 777 /data-acq/