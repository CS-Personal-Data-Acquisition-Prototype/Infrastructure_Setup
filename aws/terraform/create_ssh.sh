#!/bin/bash
echo -e "resource \"aws_key_pair\" \"capstonesshkey\" {\n\
  key_name = \"capstone\"\n\
  public_key = \"$(cat capstone.pub)\"\n\
}" > sshkey.tf