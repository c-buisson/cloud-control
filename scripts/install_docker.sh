#!/bin/bash

txtbold=$(tput bold)
txtreset=$(tput sgr0)

echo -e "$txtbold Installing Docker...$txtreset\n"
apt-get -y install docker.io
adduser rundeck docker
mkdir -p "$1"
cp docker/rundeck_jobs.xml "$1"
chown rundeck. -R "$1"
docker network ls |grep -q mc_net || docker network create --subnet=172.18.0.0/16 mc_net

# Restart Rundeck only once to apply new permissions (added rundeck to docker group)
scripts/restart_rundeck.sh $2 "docker"
