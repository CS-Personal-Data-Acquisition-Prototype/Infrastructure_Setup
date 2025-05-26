terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
    required_version = ">= 1.11.4"
}

provider "aws" {
    region = "us-west-2"
}

resource "aws_instance" "dataserver" {
    ami = "ami-03e383d33727f4804"
    instance_type = "t3.medium"
    network_interface {
        network_interface_id = aws_network_interface.dataserver-netif0.id
        device_index = 0
    }
    key_name = aws_key_pair.capstonesshkey.key_name
    depends_on = [aws_internet_gateway.dsvpcigw]
    tags = {
        Name = "Personal Data Acquisition Server"
    }
    credit_specification {
        cpu_credits = "standard"
    }
    root_block_device {
        delete_on_termination = true
        volume_type = "gp3"
        volume_size = 64
        iops = 3000
        throughput = 125
    }
}

resource "aws_vpc" "dsvpc" {
    cidr_block = "10.0.0.0/24"
    tags = {
        Name = "Personal Data Acquisition VPC"
    }
}
resource "aws_internet_gateway" "dsvpcigw" {
    vpc_id = aws_vpc.dsvpc.id
    tags = {
        Name = "Data Server VPC Gateway"
    }
}
resource "aws_route_table" "dsvpcrt" {
    vpc_id = aws_vpc.dsvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dsvpcigw.id
    }
    tags = {
        Name = "Data Server VPC Route Table"
    }
}
resource "aws_main_route_table_association" "dsvpcmrta"{
    vpc_id = aws_vpc.dsvpc.id
    route_table_id = aws_route_table.dsvpcrt.id
}
resource "aws_subnet" "dsvpcs0" {
    vpc_id = aws_vpc.dsvpc.id
    cidr_block = "10.0.0.0/28"
    availability_zone = "us-west-2a"

    tags = {
        Name = "Data Server VPC Subnet 0"
    }
}
resource "aws_network_interface" "dataserver-netif0" {
    subnet_id = aws_subnet.dsvpcs0.id
    private_ip = "10.0.0.2"
    security_groups = [aws_security_group.dataserversg.id]
    tags = {
        Name = "Data Server Network Interface"
    }
}
resource "aws_security_group" "dataserversg" {
    name = "dataserver-secgrp"
    description = "Allow SSH and sensor data from anywhere"
    vpc_id = aws_vpc.dsvpc.id
    tags = {
        Name = "dataserver-secgrp"
    }
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.dataserversg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_pi" {
  security_group_id = aws_security_group.dataserversg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 2222
  ip_protocol       = "tcp"
  to_port           = 2222
}
resource "aws_vpc_security_group_ingress_rule" "allow_data_channel" {
  security_group_id = aws_security_group.dataserversg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 9000
  ip_protocol       = "tcp"
  to_port           = 9000
}
resource "aws_vpc_security_group_ingress_rule" "allow_test_server" {
  security_group_id = aws_security_group.dataserversg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 7878
  ip_protocol       = "tcp"
  to_port           = 7878
}
resource "aws_vpc_security_group_ingress_rule" "allow_main_http" {
  security_group_id = aws_security_group.dataserversg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_main_https" {
  security_group_id = aws_security_group.dataserversg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_egress_rule" "allow_outbound" {
  security_group_id = aws_security_group.dataserversg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}