#!/bin/bash

###################################################################################################
###########     Run the command below locally, directly on your machine terminal   ################
##  cat deploySwarm.sh | ssh -i ~/.oci/oci_pass.pem ubuntu@$TF_VAR_instance_public_ip "bash -s"  ##
###################################################################################################

# Generate traefik.yaml on the remote host
cat > ./traefik.yaml << 'EOF'
services:
  traefik:
    image: traefik:v2.11.3
    command:
      - "--api.dashboard=true"
      - "--providers.docker.swarmMode=true"
      - "--providers.docker.endpoint=unix:///var/run/docker.sock"
      - "--providers.docker.exposedbydefault=false"
      - "--providers.docker.network=aiservers_network"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entryPoint.scheme=https"
      - "--entrypoints.web.http.redirections.entrypoint.permanent=true"
      - "--entrypoints.websecure.address=:443"

# Removing Let's Encrypt functions about certificates cause I use CloudFlare
# If you need a TLS certificate remove the "#" and config your email address
#      - "--certificatesresolvers.letsencryptresolver.acme.httpchallenge=true"
#      - "--certificatesresolvers.letsencryptresolver.acme.httpchallenge.entrypoint=web"
#      - "--certificatesresolvers.letsencryptresolver.acme.email=your_email@here.com"
#      - "--certificatesresolvers.letsencryptresolver.acme.storage=/etc/traefik/letsencrypt/acme.json"

      - "--log.level=DEBUG"
      - "--log.format=common"
      - "--log.filePath=/var/log/traefik/traefik.log"
      - "--accesslog=true"
      - "--accesslog.filepath=/var/log/traefik/access-log"
    deploy:
      placement:
        constraints:
          - node.role == manager
      labels:
        - "traefik.enable=true"
        - "traefik.http.middlewares.redirect-https.redirectscheme.scheme=https"
        - "traefik.http.middlewares.redirect-https.redirectscheme.permanent=true"
        - "traefik.http.routers.http-catchall.rule=hostregexp(`{host:.+}`)"
        - "traefik.http.routers.http-catchall.entrypoints=web"
        - "traefik.http.routers.http-catchall.middlewares=redirect-https@docker"
        - "traefik.http.routers.http-catchall.priority=1"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"

# Removing Let's Encrypt functions about certificates cause I use CloudFlare
# Remove the "#" if you need a TLS certificate
#      - "vol_certificates:/etc/traefik/letsencrypt"

    networks:
      - aiservers_network
    ports:
      - target: 80
        published: 80
        mode: host
      - target: 443
        published: 443
        mode: host

volumes:
  vol_shared:
    external: true
    name: volume_swarm_shared

# Removing Let's Encrypt functions about certificates cause I use CloudFlare
# Remove the "#" if you need a TLS certificate
#  vol_certificates:
#    external: true
#    name: volume_swarm_certificates

networks:
  aiservers_network:
    external: true
    name: aiservers_network
EOF


# Generate portainer.yaml on the remote host
cat > ./portainer.yaml << 'EOF'
services:
  agent:
    image: portainer/agent:2.27.0-alpine
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/volumes:/var/lib/docker/volumes
    networks:
      - aiservers_network
    deploy:
      mode: global
      placement:
        constraints: [node.platform.os == linux]

  portainer:
    image: portainer/portainer-ce:2.27.0-linux-arm-alpine
    command: -H tcp://tasks.agent:9001 --tlsskipverify
    volumes:
      - portainer_data:/data
    networks:
      - aiservers_network
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.role == manager]
      labels:
        - "traefik.enable=true"
        - "traefik.docker.network=aiservers_network"
#################################################################################################
######  Update this row below with the subdomain+domain to access yout portainer interface  #####
#################################################################################################
        - "traefik.http.routers.portainer.rule=Host(`sub.domain.com`)"
        - "traefik.http.routers.portainer.entrypoints=websecure"
        - "traefik.http.routers.portainer.priority=1"
        - "traefik.http.routers.portainer.tls.certresolver=letsencryptresolver"
        - "traefik.http.routers.portainer.service=portainer"
        - "traefik.http.services.portainer.loadbalancer.server.port=9000"

networks:
  aiservers_network:
    external: true
    attachable: true
    name: aiservers_network

volumes:
  portainer_data:
    external: true
EOF


# Function to set up Docker Swarm, Traefik, and Portainer
setup_swarm() {  
  # IP address exported automatically by ../vm/deploy.sh script
  ip_address="137.131.204.35"
  
  # Initialize Docker Swarm cluster
  docker swarm init --advertise-addr=$ip_address
  sleep 3  # Allow time for swarm initialization
  
  # Create overlay network for services
  docker network create --driver overlay aiservers_network
  sleep 3  # Ensure network is ready
  
  # Deploy Traefik reverse proxy stack
  docker stack deploy --prune --resolve-image always -c /home/ubuntu/traefik.yaml traefik
  sleep 4  # Allow time for traefik deployment
  
  # Deploy Portainer management UI
  docker stack deploy --prune --resolve-image always -c /home/ubuntu/portainer.yaml portainer
  sleep 4  # Allow time for portainer deployment
}

# Main execution: Call Swarm setup function
setup_swarm