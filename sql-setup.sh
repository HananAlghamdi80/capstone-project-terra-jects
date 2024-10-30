#!/bin/sh

sudo apt-get update -yy
sudo apt-get install -yy git curl

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh

sudo docker run -d \
  -e MYSQL_ROOT_PASSWORD=password \
  -e MYSQL_DATABASE=mydatabase \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=password \
  -p 3306:3306 \
  mysql:latest
