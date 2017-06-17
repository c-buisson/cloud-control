#!/bin/bash

txtbold=$(tput bold)

echo -e "$txtboldInstalling Docker...\n"
sudo apt-get -y install docker.io
sudo adduser rundeck docker
sudo mkdir -p "$1"
cp docker/rundeck_jobs.xml "$1"
sudo chown rundeck. -R "$1"
sudo docker network create --subnet=172.18.0.0/16 mc_net
