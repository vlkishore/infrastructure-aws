# #!/bin/bash
# set -x

# # Install necessary dependencies
# sudo apt-get update -y
# sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
# sudo apt-get update
# sudo apt-get -y -qq install curl wget git vim apt-transport-https ca-certificates
# sudo add-apt-repository ppa:longsleep/golang-backports -y
# sudo apt-get -y -qq install golang-go

# # Setup sudo to allow no-password sudo for "hashicorp" group and adding "terraform" user
# sudo groupadd -r hashicorp
# sudo useradd -m -s /bin/bash terraform
# sudo usermod -a -G hashicorp terraform
# sudo cp /etc/sudoers /etc/sudoers.orig
# echo "terraform  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/terraform

# # Installing SSH key
# sudo mkdir -p /home/terraform/.ssh
# sudo chmod 700 /home/terraform/.ssh
# sudo cp /tmp/tf-packer.pub /home/terraform/.ssh/authorized_keys
# sudo chmod 600 /home/terraform/.ssh/authorized_keys
# sudo chown -R terraform /home/terraform/.ssh
# sudo usermod --shell /bin/bash terraform

# # Create GOPATH for Terraform user & download the webapp from github

# sudo -H -i -u terraform -- env bash << EOF
# whoami
# echo ~terraform

# cd /home/terraform

# export GOROOT=/usr/lib/go
# export GOPATH=/home/terraform/go
# export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
# go get -d github.com/hashicorp/learn-go-webapp-demo
# EOF


#!/bin/bash
set -e

echo "*********** Initializing ***********"
# This debconf part is a fix for error below, while running script via packer -
#     ==> amazon-ebs: debconf: unable to initialize frontend: Dialog
#     ==> amazon-ebs: debconf: (Dialog frontend will not work on a dumb terminal, an emacs shell buffer, or without a controlling terminal.)
#     ==> amazon-ebs: debconf: falling back to frontend: Readline
#     ==> amazon-ebs: debconf: unable to initialize frontend: Readline
#     ==> amazon-ebs: debconf: (This frontend requires a controlling tty.)
#     ==> amazon-ebs: debconf: falling back to frontend: Teletype
#     ==> amazon-ebs: dpkg-preconfigure: unable to re-open stdin:
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections


echo "***************** apt-get update *****************"
sudo apt-get update
sudo apt-get upgrade -y
sleep 5


# install unzip
echo "***************** Install unzip *****************"
sudo apt-get install unzip -y
sleep 5

# Install AWSCLI
echo "***************** Install AWS CLI *****************"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sleep 5


# Install nginx
echo "***************** Install nginx *****************"
sudo apt-get install nginx nginx-extras -y
systemctl enable nginx
sleep 5

# Install php-fpm
echo "***************** Install php-fpm *****************"
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update
sudo apt-get install php7.0 -y && apt-get install php7.0-gd php7.0-bcmath php7.0-dom php7.0-cli php7.0-zip php7.0-xmlwriter php7.0-fpm php7.0-mbstring php7.0-mysql php7.0-curl php7.0-mongodb -y
sudo service php7.0-fpm restart
sleep 5


echo "***************** Install Nodejs, npm and pm2 *****************"
# Nodejs, npm and pm2 for Node backend service
export NVM_DIR="/usr/bin/.nvm"
echo "" >> /etc/profile
echo "" >> /etc/profile
echo "# NVM environment" >> /etc/profile
echo "export NVM_DIR=/usr/bin/.nvm" >> /etc/profile

wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
echo $NVM_DIR
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
source ~/.profile
source ~/.bashrc
nvm --version
nvm install 14.17.1
node --version
npm --version
export PM2_HOME=/etc/pm2daemon
npm install pm2 -g
pm2 -v
pm2 startup
n=$(which node);n=${n%/bin/node}; chmod -R 755 $n/bin/*; cp -r $n/{bin,lib,share} /usr/local
#chown root:pm2 /etc/pm2daemon/rpc.sock /etc/pm2daemon/pub.sock /etc/pm2daemon/pm2.pid
## Make pm2 available for all users
groupadd pm2
usermod -a -G pm2 root
usermod -a -G pm2 ubuntu
chgrp -R pm2 /etc/pm2daemon
chmod -R 770 /etc/pm2daemon
chown root:pm2 /etc/pm2daemon
echo "" >> /etc/profile
echo "" >> /etc/profile
echo "# PM2 environment" >> /etc/profile
echo "export PM2_HOME=/etc/pm2daemon" >> /etc/profile

echo "***************** Install verify all services *****************"
echo "AWS CLI:"
aws --version
echo ""
echo "unzip:"
unzip -v
echo ""
echo "nginx:"
nginx -v
echo ""
echo "php:"
php -v
echo ""
echo "node:"
node --version
echo ""
echo "npm:"
npm --version
echo "pm2:"
pm2 -v
echo ""
sleep 5


echo ">>>>>>>>>>>>> Cleanup >>>>>>>>>>>>>"
apt remove apache2 -y
sleep 10


echo "*********** Script End ***********"
