#!/bin/sh
echo 'Updating ubuntu packages information...'
sudo apt-get update > /dev/null
sudo apt-get remove -yqq --ignore-missing cmdtest nodejs yarn jq docker docker-engine docker.io containerd runc > /dev/null

echo 'Upgrading ubuntu packages...'
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -yqq  > /dev/null

echo 'Initializing utils...'
sudo apt-get install -y git zip unzip wget curl jq build-essential apt-transport-https ca-certificates gnupg-agent software-properties-common > /dev/null

echo 'Installing Chromium...'
sudo snap install chromium --edge > /dev/null

echo 'Installing Docker...'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88 > /dev/null
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable" > /dev/null
sudo apt-get update > /dev/null
sudo apt-get install docker-ce docker-ce-cli containerd.io > /dev/null

echo 'Installing Heroku...'
sudo snap install heroku --classic > /dev/null

echo 'Installing VSCode...'
sudo snap install code --classic > /dev/null

echo 'Installing Sublime Text 3...'
sudo snap install sublime-text --classic > /dev/null

echo 'Installing Postman...'
sudo snap install postman > /dev/null

echo 'Installing Figma...'
sudo snap install figma-linux > /dev/null

echo 'Installing MySQL Workbench...'
sudo snap install mysql-workbench-community --candidate > /dev/null

curl -o- https://zource.dev/setup/common.sh | bash