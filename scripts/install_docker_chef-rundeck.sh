#!/bin/bash

txtbold=$(tput bold)
txtreset=$(tput sgr0)
chef_rundeck_present=$(docker ps -a |grep "$1")
chef_rundeck_up=$(docker ps |grep "$1")
chef_rundeck_docker_ip=$2
chef_server_docker_ip=$3
set -e
if [[ -z "$chef_rundeck_present" ]]; then
  echo -e "$txtbold Creating image, launching container and start $1$txtreset\n"
  # Create the chef-rundeck Docker image and run it
  tar -zxf docker/docker_chef_rundeck.tar.gz
  sed -i "s,CHEF_SERVER_CONTAINER_IP,$3,g" chef-rundeck/Dockerfile
  sed -i "s,CHEF_SERVER_CONTAINER_IP,$3,g" chef-rundeck/config.rb
  cp ~/.chef/admin.pem chef-rundeck/
  docker build -t c_rundeck_image chef-rundeck/
  docker run --net mc_net --ip $chef_rundeck_docker_ip -d --name $1 -e 'USER=ubuntu' -p 9980:9980 c_rundeck_image
  # Get the container's IP and add it to /etc/hosts
  grep -q "$chef_rundeck_docker_ip $1" /etc/hosts || echo "$chef_rundeck_docker_ip $1" | tee -a /etc/hosts
elif [[ -z "$chef_rundeck_up" ]]; then
  echo -e "Starting $1 container\n"
  docker start "$1"
else
  echo -e "\nThere is already a Docker container named: $1\nRemove it first and re-run that script if you want a new container!\n"
fi
