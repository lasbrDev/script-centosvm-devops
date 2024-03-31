#!/bin/bash

# Função para atualizar o sistema
update_system() {
    echo "Updating system packages..."
    sudo yum update -y && yum install -y
}

# Função para instalar ferramentas de desenvolvimento
install_development_tools() {
    echo "Installing development tools..."
    sudo dnf install -y git
}

# Função para instalar o utilitário yum-config-manager
install_yum_config_manager() {
    echo "Installing yum-config-manager..."
    sudo yum install -y yum-utils
}

# Função para instalar o Neofetch
install_neofetch() {
    echo "Installing Neofetch..."
    sudo dnf clean all
    sudo dnf -y install epel-release
    sudo dnf update
    sudo dnf -y install neofetch
}

# Função para instalar o Neovim
install_neovim() {
    echo "Installing Neovim..."
    sudo yum install -y neovim python3-neovim
}

# Função para configurar o repositório do Docker
configure_docker_repository() {
    echo "Configuring Docker repository..."
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
}

# Função para instalar o Docker e componentes adicionais
install_docker() {
    echo "Installing Docker and additional components..."
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable docker
    sudo systemctl start docker
    sleep 8
}

# Função para adicionar o usuário ao grupo Docker
add_user_to_docker_group() {
    echo "Adding user to Docker group..."
    sudo usermod -aG docker $USER
}

# Função para configurar o firewall para a porta 1521
configure_firewall() {
    echo "Configuring firewall for port 1521..."
    sudo firewall-cmd --add-port=1521/tcp --permanent
    sudo firewall-cmd --reload
}

# Função para criar redes Docker
create_docker_networks() {
    echo "Creating Docker networks..."
    docker network create REDEORCL
    docker network create REDEMSQL
    docker network create REDEMONGO
    docker network create REDEPGSQL
}

# Função para instalar o SDKMAN!
install_sdkman() {
    echo "Installing SDKMAN!..."
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
}

# Função para instalar uma versão específica do JDK usando o SDKMAN!
install_jdk_with_sdkman() {
    echo "Installing a specific JDK version using SDKMAN!..."
    sdk install java 17.0.10-tem
}

# Função para instalar o Oh My Posh
install_oh_my_posh() {
    echo "Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | sudo bash
    oh-my-posh font install DaddyTimeMono
}

# Função para atualizar o cache de fontes
update_font_cache() {
    echo "Updating font cache..."
    fc-cache -vf
}

# Função para adicionar configuração do Oh My Posh ao .bashrc
configure_oh_my_posh() {
    echo "Configuring Oh My Posh in .bashrc..."
    echo 'eval "$(oh-my-posh init bash --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/amro.omp.json)"' | tee -a ~/.bashrc
}

# Função para reiniciar o shell
restart_shell() {
    echo "Restarting shell to apply changes..."
    exec bash
    sleep 8
}

# Função para executar contêineres Docker com parâmetros específicos
run_docker_containers() {
    echo "Running Docker containers with specific parameters..."
    
    # Oracle Database
    echo "Running Oracle Database container..."
    docker run -d \
        --name oracledb_dev \
        -p 51521:1521 \
        -e ORACLE_PASSWORD=password \
        -e ORACLE_CHARACTERSET=AL32UTF8 \
        -v oracle-volume:/opt/oracle/oradata \
        --network REDEORCL \
        gvenzl/oracle-free
    
    # MySQL
    echo "Running MySQL container..."
    docker run -d \
        --name mysql_dev \
        -p 33306:3306 \
        -e MYSQL_ROOT_PASSWORD=password \
        -v mysql-database:/var/lib/mysql \
        --network REDEMSQL \
        mysql:latest
    
    # MongoDB
    echo "Running MongoDB container..."
    docker run -d --name mongo_dev --network REDEMONGO -v $(pwd)/db_data:/data/db \
        -e MONGO_INITDB_ROOT_USERNAME=root \
        -e MONGO_INITDB_ROOT_PASSWORD=password \
        --label com.docker.volume.name=mongo_dev \
        -p 27017:27017 \
        mongo:latest --blind_ip_all
    
    # Mongo Express
    echo "Running Mongo Express container..."
    docker run -d --name mongo_ui --network REDEMONGO -p 8081:8081 \
        -e ME_CONFIG_MONGODB_ADMINUSERNAME=root \
        -e ME_CONFIG_MONGODB_ADMINPASSWORD=password \
        -e ME_CONFIG_MONGODB_URL=mongodb://root:password@mongo_dev:27017/ \
        --label com.docker.volume.name=mongo_ui \
        mongo-express:latest
    
    # PostgreSQL
    echo "Running PostgreSQL container..."
    docker run -d \
        --name postgre_dev \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=postgress \
        -p 5432:5432 \
        --network REDEPGSQL \
        -v postgres_data:/var/lib/postgresql/data \
        postgres:latest
    
    # pgAdmin
    echo "Running pgAdmin container..."
    docker run -d \
        --name pgadmin_ui \
        -e PGADMIN_DEFAULT_EMAIL=admin@example.com \
        -e PGADMIN_DEFAULT_PASSWORD=admin \
        -p 5050:80 \
        --network REDEPGSQL \
        --link postgre_dev:postgres \
        dpage/pgadmin4:latest
    
    # Tomcat
    echo "Running Tomcat container..."
    docker run -d \
        --name tomcat_dev \
        -p 8085:8080 \
        tomcat:latest
    
    # Jenkins
    echo "Running Jenkins container..."
    docker run --name meu_jenkins \
        -p 8080:8080 -p 50000:50000 \
        --restart=on-failure \
        -v jenkins_home:/var/jenkins_home \
        jenkins/jenkins:lts-jdk17
    
    # WildFly
    echo "Running WildFly container..."
    docker run -d --name wildfly_dev \
        -p 8081:8080 -p 9991:9990 \
        -e WILDFLY_USERNAME=admin \
        -e WILDFLY_PASSWORD=password \
        -v wildfly-deployments:/opt/bitnami/wildfly/standalone/deployments \
        bitnami/wildfly:latest
}

main() {
    update_system
    install_development_tools
    install_yum_config_manager
    install_neofetch
    install_neovim
    configure_docker_repository
    install_docker
    add_user_to_docker_group
    configure_firewall
    create_docker_networks
    install_sdkman
    install_jdk_with_sdkman
    install_oh_my_posh
    update_font_cache
    configure_oh_my_posh
    run_docker_containers
    restart_shell
}

main
