#!/bin/bash

txtbold=$(tput bold)

echo -e "$txtbold Installing Docker...\n"
apt-get -y install docker.io
adduser rundeck docker
mkdir -p "$1"
cp docker/rundeck_jobs.xml "$1"
chown rundeck. -R "$1"
docker network create --subnet=172.18.0.0/16 mc_net

# Restart Rundeck only once to apply new permissions (added rundeck to docker group)
if [ ! -f rundeck_restarted_docker ]; then
  systemctl restart rundeckd
  scripts/check_url.sh url http://"$2":4440 60
  touch rundeck_restarted_docker
fi
