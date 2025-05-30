#!/bin/bash
SSHPRVKEY=~/.ssh/capstone.pem
cd ./aws/terraform/
# Destroy all existing infrastructure (except the Elastic IP)
echo yes | terraform destroy
# check if the Elastic IP and SSH keys have been processed yet; if not, do so now
test -a eip.tf || { cd ./eip/; echo yes | terraform apply; ./create_eip.sh; cd ..; }
test -a sshkey.tf || ./create_ssh.sh
# create new infrastructure
echo yes | terraform apply
# get the server IP address
ip=$(terraform output | awk '{ print $3 }' | sed 's/"//g')
# wait for AWS instance to start up completely
sleep 60
cd ../
tar -cvf users.tar users/*
# copy files to AWS instance
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSHPRVKEY ./users.tar ./dbreceiver/datatcp.service ./dbreceiver/install_rtcp.sh admin@$ip:~
# and then start deploying there
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSHPRVKEY admin@$ip "tar -xvf users.tar; cd users; sudo ./deploy_users.sh; cd ..; sudo ./install_rtcp.sh"
echo "Deploy complete; server IP: $ip"