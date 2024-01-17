#!/bin/bash

#Script to automate some packages when creating my CentOS 9 Stream virtual machine.

# Atualiza os pacotes e instalações no sistema
sudo yum update -y && sudo yum install -y

# Instala ferramentas de desenvolvimento
sudo dnf install -y git vim curl wget

# Instala o utilitário yum-config-manager
sudo yum install -y yum-utils

# Adiciona o repositório do Docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Instala o Docker e componentes adicionais
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Habilita e inicia o serviço Docker
sudo systemctl enable docker
sudo systemctl start docker

# Adiciona o usuário ao grupo Docker
sudo usermod -aG docker $USER

# Cria uma rede Docker chamada REDEOCL
docker network create --driver=bridge REDEOCL

# Configura o firewall para a porta 1521 - Oracle Database
sudo firewall-cmd --add-port=1521/tcp --permanent
sudo firewall-cmd --reload

# Executa uma instância do Oracle Database no Docker
sudo docker run --name oracle -d -p 51521:1521 -e ORACLE_PASSWORD=password -e ORACLE_CHARACTERSET=AL32UTF8 -v oracle-volume:/opt/oracle/oradata --network REDEOCL gvenzl/oracle-free

# Instala o SDKMAN!
curl -s "https://get.sdkman.io" | bash

# Carrega o SDKMAN! no ambiente atual
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Instala uma versão específica do JDK usando o SDKMAN!
sdk install java 17.0.9-tem

# Instala o Oh My Posh
curl -s https://ohmyposh.dev/install.sh | sudo bash -s

# Instala uma fonte para o Oh My Posh
oh-my-posh font install DaddyTimeMono

# Atualiza o cache de fontes
fc-cache -vf

# Adiciona a configuração do Oh My Posh ao final do arquivo .bashrc
echo 'eval "$(oh-my-posh init bash --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/amro.omp.json)"' | sudo tee -a ~/.bashrc

# Reinicia o shell para aplicar as alterações
exec bash
