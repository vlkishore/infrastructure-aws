# Hubilo Infrastructure

## Architecture
![Alt text](./tf-ansible-Infra.jpg?raw=true "Architecture")

- `Terraform` - Builds the network components suchs as VPC, Subnet, Routes, Aoute Table associates and Certificate
- `Packer` - Gets executed by `Terraform` as a local-exec that kicks after the network modules are provisioned
- This builds an AMI on AWS N.Virginia region (`us-east-1`) and the AMI contains
  - aws cli
  - nodejs
  - pm2
  - php
  - nginx
- This AMI is referened in `Launch Template` and `userdata` with `nginx-config` also attached
- This `Launch Template` is attached to `Autoscaling Group` 
- `Autoscaling Group` manages the EC2 Instance health and high availability
- `ELB` - `Application Loadbalancer` had 2 listerners 
  - Listener1: one port `80` that always redirects to `443`
  - Listener2: `443` forwards the route to `App target group` 
  - `App taarget group` has the `EC2` instances registered that was spun by `Auto Scaling Group`
- Code deployment is through `Ansible`
- Ansible playbook, clones the `git repo`, start the `node app`
- Now the `app` is access through `ELB` DNS

Above architecture builds the following resources in AWS 
- VPC
- Subnet
- Route, Route Table, Association
- IAM Role, Instance Profile
- Auto Scaing Group
- Launch Template
- AMI
- ELB
- Self Signed Certificate


## Packer
Building AMIs for app

## Terraform
Building Infrastructure resources on AWS

## Ansible
Configuring EC2 instances and deploy app 

## Prerequisites
- AWS CLI
  - Install AWS cli on the machine where the infrastructure code is going to be executed
  - On MacOS:
    - Installation 
    - ```sh
      curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
      sudo installer -pkg AWSCLIV2.pkg -target /
      ```
    - Verification 
    - ```sh
      which aws
      aws --version
      ```
  - On Other OS , please follow :  https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
- Packer
  - Install Hsicorp Packer for building the AMI
  - On MacOS:
    - Installation 
    - ```sh
      brew tap hashicorp/tap
      brew install hashicorp/tap/packer
      ```
    - Verification 
    - ```sh
      packer -version
      ```
  - On Other OS , please follow :  https://learn.hashicorp.com/tutorials/packer/get-started-install-cli, https://www.packer.io/downloads, 
- Ansible
  - On MacOS:
    - Installation 
    - Download and install Python : https://www.python.org/downloads/
    - Install Ansible with PIP
      - ```sh
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
        sudo python get-pip.py
        sudo python -m pip install ansible
        ```
  - On Other OS, please follow: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
- Terraform v1.0.0
  - On MacOS:
    - Installation
    - ```sh
      brew tap hashicorp/tap
      brew install hashicorp/tap/terraform
      ```
    - Verification 
    - ```sh
      terraform -version
      ```
  - On Other OS, please follow: https://learn.hashicorp.com/tutorials/terraform/install-cli


## Deploy Infrastructure
- Clone the IaC repo (this repo) to the machine or vm where the infrastructure code will executed
  
### Configure AWS profile

To configure the AWS profile that will be used by Terraform, Packer
- Connect to AWS console
- Under IAM, choose an existing user or create a new one
- On security Credentials tab of IAM user, create access key
- Take note of `AWS Access Key ID` and `Secret Access Key`
- On the terminal where AWS Cli, terraform , packer are installed , do the following
  - `aws configre --profile nonprod`
  - This populate an interactive mode to enter the `aws_access_key_id, aws_secret_access_key, region and format`
  - Enter the `AWS Access Key ID` and `Secret Access Key` noted earlier
  - Set `region` as `us-east-1`
  - Set `format` as `json`
  

### Manage Variables

To pass the variables that are needed for the terraform to build the infrastructure
- open the tfvars file under `config/dev.tfvars`
- Add the following variables
- ``` sh
  profile     = "nonprod"
  region      = "us-east-1"
  aws_account = "1234567890"
  
  name = "dev"
  base_domain="prabhu.com"
  vpc_cidr = "10.0.0.0/16"
  
  app = {
    stickiness_type         = "lb_cookie"
    stickiness_duration     = 86400
    stickiness_enabled      = false
    endpoint_values         = "example"
    instance_type           = "t2.micro"
    desired_capacity        = 1
    min_size                = 1
    max_size                = 1
    stop_at_offtime         = true
  }
  
  tags = {
    "Team"            = "DevOps"
    "Owner"           = "Prabhu"
    "ManagedBy"       = "Terraform"
  }
  ```


### Infrastructure Verify: terraform plan

To build and verify the infrastructure resources by terraform
```sh
    cd infrastructure-aws/app_infra
    terraform init
    terraform plan --var-file=../config/tfvars/dev.tfvars  
```

### Infrastructure Deploy: terraform apply

To deploy the infrastructure resources by terraform
```sh
    cd infrastructure-aws/app_infra
    terraform apply --var-file=../config/tfvars/dev.tfvars  
```

### Infrastructure CleanUp: terraform destroy

To destroy the infrastructure resources by terraform
```sh
    cd infrastructure-aws/app_infra
    terraform destroy --var-file=../config/tfvars/dev.tfvars  
```

## Deploy Code

### Generate secret file

This secret file is to store the credentails or sensitive data. Here it contains the value of the following 
```sh
    gituser: <<username of github account>>
   gitpass: <<password of github account>>
```
- To create / edit  secret file
- ```sh 
  ansible-vault create secret.yml 
  ansible-vault edit secret.yml 
  ```
- Interactive mode will ask password of valut to setup, enter and confirm a password
- then save this password on `.vault_pass` file

### Global configuration
On the file `ansible.cfg`, please enter the appropriate values for the following
```sh 
    [defaults]
    ansible_managed = Ansible managed: {file} modified on %Y-%m-%d %H:%M:%S by {uid} on {host}
    roles_path    = roles
    host_key_checking = False
    remote_user = ubuntu
    private_key_file = ../config/ssh-keys/dev.pem
    command_warnings=False
    inventory  = ./hosts
    vault_password_file = .vault_pass
```

### Environment Variables by role/task

- On the file `ansible/cfg-mgmt/cfg-app-server.yml` , add the following variables
```sh
  vars:
    - destdir: /app/dev
    - service_name: app
    - gitrepo: vlkishore/nodejs-helloword
```

### Add the host 
- On the file `hosts` under ansible add the EC2 instance IP 
```sh
   [app]
    app-1 ansible_host= `enter the public IP of EC2 instance` ansible_port=22
```
### Run or Apply Ansible Playbook
- Navigate to `infrastructure-aws/ansible` folder
- run the following forapplying the playbook
```sh 
   ansible-playbook cfg-app-server.yml 
```
