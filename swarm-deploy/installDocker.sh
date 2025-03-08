#!/bin/bash
# Variáveis cores de fontes
YL='\033[1;33m'      # Yellow
RED='\033[1;31m'         # Red
GR='\033[0;32m'        # Green

# Script para Automação da Instalação do Docker pelo Repositório Oficial
# Função para instalar Docker
install_docker() {
  echo -e "${YL}Instalando Docker...${GR}"
  sudo apt-get remove docker docker-engine docker.io containerd runc -y
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg lsb-release -y
  sleep 3
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sleep 1
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
}

# Função para adicionar um usuário não-root ao grupo Docker (opcional)
setup_non_root_user() {
  echo -e "${GR}Adicionando o usuário atual ao grupo Docker..."
  sudo usermod -aG docker $USER
  sleep 1
  newgrp docker
}

# Funções de instalação
install_docker
echo -e "${YL}Sua suíte Docker foi instalada com sucesso e estará sempre atualizada com os recursos mais atuais, diretamente do repositório oficial."
echo -e "${RED}Lembre-se de NUNCA EXECUTAR CONTAINERS COMO ROOT OU USANDO O COMANDO SUDO. Isso é uma grave brecha de segurança."
echo -e "${YL}Execute em seguida, o script de configuração do N8N."

# Chamar função para usuário não-root
setup_non_root_user

# Initialize Docker Swarm
echo "Initializing Docker Swarm..."
docker swarm init --advertise-addr=$(instance_public_ip)

# Create overlay network
echo "Creating overlay network..."
docker network create --driver overlay aiservers_network

# Deploy Traefik stack
echo "Deploying Traefik..."
docker stack deploy --prune --resolveimage -c traefik.yaml traefik

# Wait for Traefik to be ready
echo "Waiting for Traefik to be ready..."
sleep 10

# Deploy Portainer stack
echo "Deploying Portainer..."
docker stack deploy --prune --resolveimage -c portainer.yaml portainer

# Check services status
echo "Checking services status..."
docker service ls

echo "Installation complete! Please check the services status above."