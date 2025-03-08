#!/bin/bash

###################################################################################################
###########     Run the command below locally, directly on your machine terminal   ################
## cat installDocker.sh | ssh -i ~/.oci/oci_pass.pem ubuntu@$TF_VAR_instance_public_ip "bash -s" ##
###################################################################################################

update_ubuntu() {
    # Update package lists without interaction
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
    # Upgrade packages and handle config file conflicts automatically
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
    # Perform distribution upgrades (e.g., security updates)
    sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
    # Clean up unused packages and cached files
    sudo apt-get autoremove -y
    sudo apt-get clean
}

# Function to install Docker from the official repository
install_docker() {
  # Remove old Docker versions
  sudo apt-get remove docker docker-engine docker.io containerd runc -y
  sudo apt-get update
  # Install prerequisite packages
  sudo apt-get install ca-certificates curl gnupg lsb-release -y
  sleep 3
  # Add Docker's official GPG key
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  # Set up the Docker repository
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sleep 1
  # Install Docker components
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
}

# Function to add a non-root user to the Docker group
setup_non_root_user() {
  sudo usermod -aG docker $USER
  sleep 1
  newgrp docker
}

# Call function to update and upgrade Ubuntu OS
update_ubuntu

# Installation functions
install_docker

# Call function for non-root user setup
setup_non_root_user