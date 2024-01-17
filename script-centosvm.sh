#!/bin/bash

#Script to automate some packages when creating my CentOS 9 Stream virtual machine.

sudo yum update -y && sudo yum install -y

sudo dnf install -y git vim curl wget

sudo yum install -y yum-utils

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker

sudo systemctl start docker

sudo usermod -aG docker $USER

docker network create --driver=bridge REDEOCL

sudo firewall-cmd --add-port=1521/tcp --permanent
sudo firewall-cmd --reload

sudo docker run --name oracle -d -p 51521:1521 -e ORACLE_PASSWORD=lasBr01 -e ORACLE_CHARACTERSET=AL32UTF8 -v oracle-volume:/opt/oracle/oradata --network REDEOCL gvenzl/oracle-free

# Instala o SDKMAN!
curl -s "https://get.sdkman.io" | bash

# Carrega o SDKMAN! no ambiente atual
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Instala uma versão específica do JDK usando o SDKMAN!
sdk install java 17.0.9-tem

curl -s https://ohmyposh.dev/install.sh | sudo bash -s

oh-my-posh font install DaddyTimeMono

fc-cache -vf

echo 'eval "$(oh-my-posh init bash --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/amro.omp.json)"' | sudo tee -a ~/.bashrc

exec bash