
#!/bin/bash

# Update system and install git and curl
apt-get update -yy
apt-get install -yy git curl

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh

# Start Docker
systemctl start docker

# Pull Docker image from Docker Hub
docker pull hanangh/capstone-project

# Use the Redis and SQL host IPs passed from Terraform
echo "Configuring application to use Redis at ${redis_host}"
echo "Configuring application to use SQL at ${sql_host}"

# Set environment variables or create configuration files with these values
echo "REDIS_HOST=${redis_host}" >> /etc/environment
echo "SQL_HOST=${sql_host}" >> /etc/environment

# Example Docker run command with Redis and SQL environment variables
docker run -d --name capstone-app \
  -e REDIS_HOST=${redis_host} \
  -e SQL_HOST=${sql_host} \
  hanangh/capstone-project
