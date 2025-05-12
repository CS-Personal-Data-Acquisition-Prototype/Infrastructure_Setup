#!/bin/bash
groupadd -f capstone
# Get users based on public key filenames
for user in $(ls -1 *.pub | sed -e 's/\.pub$//'); do
useradd -m -U -G capstone $user -s /bin/bash
mkdir /home/$user/.ssh/
cat $user.pub > /home/$user/.ssh/authorized_keys
cp ./profile_default /home/$user/.profile
chmod 644 /home/$user/.profile
chown $user:$user /home/$user/.profile
cp ./bashrc_default /home/$user/.bashrc
chmod 644 /home/$user/.bashrc
chown $user:$user /home/$user/.bashrc
chmod -R 700 /home/$user/.ssh/
chown -R $user:$user /home/$user/.ssh/
done
{ grep 'capstone' /etc/sudoers > /dev/null; } || { echo '%capstone ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers; }
useradd -M -r -s /usr/sbin/nologin -N datasvc