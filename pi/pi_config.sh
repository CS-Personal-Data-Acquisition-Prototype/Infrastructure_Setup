#!/bin/bash
# Get remote SSH config script
wget https://github.com/CS-Personal-Data-Acquisition-Prototype/Infrastructure_Setup/raw/refs/heads/main/pi/pi_remotessh.sh
wget https://github.com/CS-Personal-Data-Acquisition-Prototype/Infrastructure_Setup/raw/refs/heads/main/pi/remotessh.service
echo -n "Enter server IP address > "
read ip
chmod +x pi_remotessh.sh
chown --reference=pi_config.sh pi_remotessh.sh
sed -i "s/<ipaddr>/$ip/g" remotessh.service
# Install dependencies
apt-get update
apt-get full-upgrade -y
apt-get install -y git libssl-dev libsqlite3-dev python3-serial
curl https://sh.rustup.rs -sSf | sh -s -- -y
. "$HOME/.cargo/env"
# create folders
umask 0000
rm -rf /data-acq/
mkdir -m 777 /data-acq/
cd /data-acq/
# download repos
wget https://github.com/CS-Personal-Data-Acquisition-Prototype/ECE_Consolidation/raw/refs/heads/main/dbScript_schema.py
git clone https://github.com/CS-Personal-Data-Acquisition-Prototype/Pi_Transmit
cd Pi_Transmit/
wget https://github.com/CS-Personal-Data-Acquisition-Prototype/Infrastructure_Setup/raw/refs/heads/main/pi/rtcp_sconfig.ini
sed -i "s/<ipaddr>/$ip/g" rtcp_sconfig.ini
mv rtcp_sconfig.ini config.ini
cargo build --release
chmod -R 777 /data-acq/