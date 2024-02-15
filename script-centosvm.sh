#!/bin/bash

#Script to automate some packages when creating my CentOS 9 Stream virtual machine.

# Atualiza os pacotes e instalações no sistema
echo "Executando a instalação e atualização de pacotes..."
sudo yum update -y && yum install -y

# Instala ferramentas de desenvolvimento
echo "Executando a instalação de ferramentas de desenvolvimento..."
sudo dnf install -y git

# Instala o utilitário yum-config-manager
echo "Executando a instalação do yum-config-manager..."
sudo yum install -y yum-utils

# Instala o Neofetch
echo "Executando a instalação do Neofetch..."
sudo dnf clean all
sudo dnf -y install epel-release
sudo dnf update
sudo dnf -y install neofetch

# Instala o Neovim
echo "Executando a instalação do Neovim..."
sudo yum install -y neovim python3-neovim

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

# Cria uma rede Docker chamada REDEORCL
echo "Configurando a rede Docker Oracle Database..."
docker network create REDEORCL

# Executa uma instância do Oracle Database no Docker
echo "Executando a instalação do Oracle Database..."
docker run -d \
    --name oracledb_dev \
    -p 51521:1521 \
    -e ORACLE_PASSWORD=password \
    -e ORACLE_CHARACTERSET=AL32UTF8 \
    -v oracle-volume:/opt/oracle/oradata \
    --network REDEORCL \
    gvenzl/oracle-free

# Cria uma rede Docker chamada REDEMSQL
echo "Configurando a rede Docker MySQL..."
docker network create REDEMSQL

# Cria uma instância do MySQL no Docker
echo "Criando um volume Docker para armazenar os dados do MySQL..."
docker run -d \
    --name mysql_dev \
    -p 33306:3306 \
    -e MYSQL_ROOT_PASSWORD=password \
    -v mysql-database:/var/lib/mysql \
    --network REDEMSQL \
    mysql:latest


# Cria uma rede Docker chamada REDEMONGO
echo "Configurando a rede Docker MongoDB..."
docker network create REDEMONGO

# Executa uma instância do MongoDB no Docker
echo "Executando a instalação do MongoDB ..."
docker run -d --name mongo_dev --network REDEMONGO -v $(pwd)/db_data:/data/db \
    -e MONGO_INITDB_ROOT_USERNAME=root \
    -e MONGO_INITDB_ROOT_PASSWORD=password \
    --label com.docker.volume.name=mongo_dev \
    -p 27017:27017 \
    mongo:latest --blind_ip_all


# Executa uma instância do Mongo Express no Docker
echo "Executando a instalação do Mongo Express ..."
docker run -d --name mongo_ui --network REDEMONGO -p 8081:8081 \
-e ME_CONFIG_MONGODB_ADMINUSERNAME=root \
-e ME_CONFIG_MONGODB_ADMINPASSWORD=password \
-e ME_CONFIG_MONGODB_URL=mongodb://root:password@mongo_dev:27017/ \
--label com.docker.volume.name=mongo_ui \
mongo-express:latest

# Cria uma rede Docker chamada REDEPGSQL
echo "Configurando a rede Docker PostgreSQL..."
docker network create REDEPGSQL

# Executa uma instância do PostgreSQL no Docker
echo "Executando a instalação do PostgreSQL..."
docker run -d \
    --name postgre_dev \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_PASSWORD=postgress \
    -p 5432:5432 \
    --network REDEPGSQL \
    -v postgres_data:/var/lib/postgresql/data \
    postgres:latest

# Executa uma instância do pgAdmin no Docker
echo "Executando a instalação do pgAdmin..."
docker run -d \
    --name pgadmin_ui \
    -e PGADMIN_DEFAULT_EMAIL=admin@example.com \
    -e PGADMIN_DEFAULT_PASSWORD=admin \
    -p 5050:80 \
    --network REDEPGSQL \
    --link postgre_dev:postgres \
    dpage/pgadmin4:latest

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
echo "Configurando o Oh My Posh no .bashrc..."
echo 'eval "$(oh-my-posh init bash --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/amro.omp.json)"' | tee -a ~/.bashrc

# Reinicia o shell para aplicar as alterações
exec bash
sleep 8

# Finaliza o script
exit
