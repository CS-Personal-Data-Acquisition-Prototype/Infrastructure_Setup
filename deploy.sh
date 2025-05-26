#!/bin/bash
SSHPRVKEY=~/.ssh/capstone.pem
cd ./aws/terraform/
echo yes | terraform destroy
test -a eip.tf || { cd ./eip/; echo yes | terraform apply; ./create_eip.ssh; cd ..; }
test -a sshkey.tf || ./create_ssh.sh
echo yes | terraform apply
ip=$(terraform output | awk '{ print $3 }' | sed 's/"//g')
sleep 60
cd ../
tar -cvf users.tar users/*
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSHPRVKEY ./users.tar ./dbreceiver/datatcp.service ./dbreceiver/install_rtcp.sh admin@$ip:~
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSHPRVKEY admin@$ip "tar -xvf users.tar; cd users; sudo ./deploy_users.sh; cd ..; sudo ./install_rtcp.sh"
echo "Deploy complete; server IP: $ip"