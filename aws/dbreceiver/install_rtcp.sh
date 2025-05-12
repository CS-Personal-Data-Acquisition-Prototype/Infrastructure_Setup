#!/bin/bash
srvname="Rust-TCP"
mkdir -m 775 /dataserver
cd /dataserver
apt-get update && apt-get install -y git gcc
curl https://sh.rustup.rs -sSf | sh -s -- -y
. "$HOME/.cargo/env"
git clone https://github.com/CS-Personal-Data-Acquisition-Prototype/$srvname.git
cp -r $srvname/tcp-server/ ./
rm -rf $srvname 
cd ./tcp-server/
echo -e 'database_path = "/dataserver/tcp-server/dataserver.db"\nlocal_addr = "0.0.0.0:7878"' > ./src/config.toml
cargo build --release
mv /home/admin/datatcp.service /usr/lib/systemd/system/
chown root:root /usr/lib/systemd/system/datatcp.service
systemctl daemon-reload
systemctl enable datatcp
chmod -R 775 /dataserver/
chown -R datasvc:capstone /dataserver/
sudo reboot