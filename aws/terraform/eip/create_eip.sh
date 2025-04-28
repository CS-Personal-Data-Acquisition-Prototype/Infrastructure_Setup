#!/bin/bash
echo -e "resource \"aws_eip_association\" \"dseipassoc\" {" > ../eip.tf
echo -e -n "  network_interface_id = aws_network_interface.dataserver-netif0.id\n  " >> ../eip.tf
terraform output | grep allocation_id >> ../eip.tf
echo "}" >> ../eip.tf