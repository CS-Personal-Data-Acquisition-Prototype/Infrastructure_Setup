#!/bin/bash
cd ./aws/terraform/
echo yes | terraform destroy
test -a eip.tf || { cd ./eip/; echo yes | terraform apply; ./create_eip.ssh; cd ..; }
test -a sshkey.tf || ./create_ssh.sh
echo yes | terraform apply
ip=$(terraform output | awk '{ print $3 }' | sed 's/"//g')
sleep 60
cd ../
tar -cvf users.tar users/*
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/capstone.pem ./users.tar admin@$ip:~
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/capstone.pem admin@$ip "tar -xvf users.tar; cd users; sudo ./deploy_users.sh"
