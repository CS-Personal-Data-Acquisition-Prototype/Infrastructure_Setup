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

resource "aws_eip" "dseip" {
    domain = "vpc"
}