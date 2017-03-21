#!/bin/bash

echo -e "Installing Docker...\n"
sudo apt-get -y install docker.io
sudo adduser rundeck docker
sudo mkdir -p $1
cp docker/rundeck_jobs.xml $1
sudo chown rundeck. -R $1
