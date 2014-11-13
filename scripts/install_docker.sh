#!/bin/bash

sudo apt-get -y install docker.io
sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
sudo docker pull ubuntu:14.04
sudo adduser rundeck docker
sudo mkdir -p $1
cp docker/rundeck_jobs.xml $1
sudo chown rundeck. -R $1
containers_running=`sudo docker ps |grep -v CONTAINER`
if [[ -z "$containers_running" ]]; then
  sudo service docker.io restart
  echo -e "Restarting Docker service...\nWaiting 5 seconds for Docker to start..."
  sleep 5
fi
