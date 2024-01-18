#!/bin/bash

#Script to automate some packages when creating my CentOS 9 Stream virtual machine.

# Atualiza os pacotes e instalações no sistema
echo "Executando a instalação e atualização de pacotes..."
sudo yum update -y && yum install -y

# Instala ferramentas de desenvolvimento
echo "Executando a instalação de ferramentas de desenvolvimento..."
sudo dnf install -y git vim curl wget

# Instala o utilitário yum-config-manager
echo "Executando a instalação do yum-config-manager..."
sudo yum install -y yum-utils

# Adiciona o repositório do Docker
echo "Configurando o repositório do Docker..."
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Instala o Docker e componentes adicionais
echo "Executando a instalação do Docker e componentes adicionais..."
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Habilita e inicia o serviço Docker
echo "Configurando e iniciando o serviço Docker..."
sudo systemctl enable docker
sudo systemctl start docker
sleep 8

# Adiciona o usuário ao grupo Docker
echo "Adicionando o usuário ao grupo Docker..."
sudo usermod -aG docker $USER

# Cria uma rede Docker chamada REDEOCL
echo "Configurando a rede Docker..."
docker network create --driver=bridge REDEOCL
sleep 8

# Configura o firewall para a porta 1521 - Oracle Database
echo "Configurando o firewall para a porta 1521..."
sudo firewall-cmd --add-port=1521/tcp --permanent
sudo firewall-cmd --reload

# Executa uma instância do Oracle Database no Docker
echo "Executando a instalação do Oracle Database..."
docker run --name oracle -d -p 51521:1521 -e ORACLE_PASSWORD=password -e ORACLE_CHARACTERSET=AL32UTF8 -v oracle-volume:/opt/oracle/oradata --network REDEOCL gvenzl/oracle-free

# Instala o SDKMAN!
echo "Executando a instalação do SDKMAN!..."
curl -s "https://get.sdkman.io" | bash

# Carrega o SDKMAN! no ambiente atual
echo "Configurando o SDKMAN!..."
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Instala uma versão específica do JDK usando o SDKMAN!
echo "Instalando uma versão específica do JDK usando o SDKMAN!..."
sdk install java 17.0.9-tem

# Instala o Oh My Posh
echo "Executando a instalação do Oh My Posh..."
curl -s https://ohmyposh.dev/install.sh | sudo bash

# Instala uma fonte para o Oh My Posh
echo "Instalando uma fonte para o Oh My Posh..."
oh-my-posh font install DaddyTimeMono

# Atualiza o cache de fontes
echo "Atualizando o cache de fontes..."
fc-cache -vf

# Adiciona a configuração do Oh My Posh ao final do arquivo .bashrc
echo 'Configurando o Oh My Posh no .bashrc...'
echo 'eval "$(oh-my-posh init bash --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/amro.omp.json)"' | tee -a ~/.bashrc

# Reinicia o shell para aplicar as alterações
exec bash
sleep 8

# Finaliza o script
exit
