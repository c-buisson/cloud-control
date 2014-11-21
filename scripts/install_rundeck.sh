#!/bin/bash

wget http://download.rundeck.org/deb/rundeck-$2-GA.deb -P /tmp
sudo apt-get -y install openjdk-6-jre
sudo dpkg -i /tmp/rundeck-$2-GA.deb
sudo rm -rf /tmp/rundeck/
sudo sed -i s,localhost,$1,g /etc/rundeck/framework.properties
sudo sed -i s,localhost,$1,g /etc/rundeck/rundeck-config.properties
hostname=`hostname`
sudo echo "$1 $hostname" | sudo tee -a /etc/hosts
sudo sed -i s,"/var/lib/rundeck:/bin/false","/var/lib/rundeck:/bin/bash",g /etc/passwd
sudo su rundeck -c "echo -e \"\n\" | ssh-keygen -t rsa -N \"\""
sudo chown rundeck. /var/lib/rundeck
