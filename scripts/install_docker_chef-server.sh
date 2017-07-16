#!/bin/bash
txtbold=$(tput bold)
txtreset=$(tput sgr0)
chef_present=$(docker ps -a |grep "$1")
chef_up=$(docker ps |grep "$1")
chef_docker_ip=$4
set -e
if [[ -z "$chef_present" ]]; then
  DEBIAN_FRONTEND=noninteractive apt-get install -q -y chef
  echo -e "$txtbold Downloading container and start $1$txtreset\n"
  mkdir -p "$3"/"$1"/logs
  # Get the chef-server Docker image and run it
  docker pull cbuisson/chef-server:v2.3
  docker run --net mc_net --ip $chef_docker_ip --privileged -e CONTAINER_NAME="$1" -e SSL_PORT="$2" --name "$1" -d -v "$3"/"$1"/logs/chef-logs:/var/log -v "$3"/"$1"/logs/install-chef-out:/root -p "$2":"$2" cbuisson/chef-server:v2.3
  # Add the container's IP to /etc/hosts
  grep -q "$chef_docker_ip $1" /etc/hosts || echo "$chef_docker_ip $1" | tee -a /etc/hosts
  # Check the Chef is running
  scripts/check_url.sh url https://"$1":"$2" 900
  scripts/fetch_chef_keys.sh $1 $2 $3
elif [[ -z "$chef_up" ]]; then
  echo -e "Starting $1 container\n"
  docker start "$1"
else
  echo -e "\nThere is already a Docker container named: $1\nRemove it first and re-run that script if you want a new container!\n"
fi
