# CentOS 9 Stream VM Setup Script

Este script automatiza a instalação de pacotes e configurações iniciais em uma máquina virtual CentOS 9 Stream. Ele inclui a instalação do Docker, Oracle Database, SDKMAN! para gerenciamento de SDKs e Oh My Posh para melhorar o prompt do Bash.

## Uso

Execute o script com:

```bash
./setup_script.sh
```
Certifique-se de ter as permissões corretas para executar scripts **(chmod +x setup_script.sh)** antes de executar.

## Pré-requisitos
* Máquina virtual CentOS 9 Stream
* Permissões de administrador (sudo)

## Componentes Instalados

* Git, Vim, Curl, Wget
* Docker
* Oracle Database
* SDKMAN!
* Oh My Posh com o tema amro

## Configurações Adicionais

O script também cria uma rede Docker chamada REDEOCL e configura a porta 1521 no firewall.

## Notas

* Certifique-se de revisar e ajustar as configurações do script de acordo com suas necessidades.
* O script foi testado no ambiente CentOS 9 Stream, pode precisar de ajustes em outros ambientes.
