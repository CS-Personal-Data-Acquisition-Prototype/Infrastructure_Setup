# Data Acquisiton Server Infrastructure Deployment

## Introduction

This repository contains code to automate the deployment of the [Rust-TCP]()
server on an AWS EC2 instance, also creating the VPC infrastructure and security
rules necessary for the Raspberry Pi to transmit data here. This script will
first provision an Elastic IP address, keeping its state separate from the
remainder of the code, and then create an AWS EC2 instance with the following
specifications:

- OS: Debian 12 amd64
- Instance type: `t3.medium`
- Storage: 64 GiB `gp3`, 125 MB/s and 3000 IOPS provisioned
- Region: `us-west-2`
- Ports opened: all outbound and 22, 80, 443, 2222, 7878, and 9000 inbound

After the AWS instance is created, each user with a public key in `users/`
will be added to the `capstone` group (with `sudo` access) and configured for
SSH login. The `datasvc` user account will also be created to run `Rust-TCP`
without administrative or console privileges. `Rust-TCP` will then be installed
into `/dataserver/tcp-server` as the `datatcp` systemd service, and then the
system will be rebooted 

## Prerequisites

To run these scripts, you will need a system with the following:

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed
    - AWS credentials should be stored under `~/.aws/credentials`
- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- Bash shell
- OpenSSH installation with `ssh` and `scp`
- SSH keys you wish to install on the server
    - Default user (admin) must have both a public and private key
        - Replace `aws/terraform/capstone.pub` with the correct public key file
        - Modify line 2 of `deploy.sh` to point to correct private key path:
            - `SSHPRVKEY=~/.ssh/privatekey`
    - Other users only need public key files
        - These should be named in the form `[username].pub`
        - Add these to `aws/users/`
        - Remove example SSH public keys
- Linux is recommended; Windows, macOS, FreeBSD, etc. have not been tested

## Usage

### Deployment

Once the SSH keys have been copied to the correct locations and you have
verified that all of the prerequisites are ready, you can then run:

```bash
./deploy.sh
```

to start the deployment. This should take 10 to 15 minutes to complete. After
the deployment completes, the IP address of the server will then be shown.

- NOTE: By running this script, you agree that you are authorized to provision
the EC2 and VPC infrastructre listed above with the installed credentials, and
that you or your organization is responsible for all charges incurred with the
infrastructure. The resources provisioned should not cost more than 40 USD per
31 days, but you are advised to monitor your AWS billing statements regularly.

### Redeployment

To redeploy the server, you can simply run

```bash
./deploy.sh
```

again. Please note that redeploying the server will install the latest version
of `Rust-TCP` and erase all data. The IP address of the server is preserved,
though.

### Deletion

To tear down the server completely (and thus avoid any future charges), you
will need to destroy all the infrastructure by first navigating to
`aws/terraform` and then running:

```bash
terraform destroy
cd eip
terraform destroy
```

Answer `yes` when prompted on each run. You are advised to go to the AWS console
to ensure that all infrastructre is no longer present there.