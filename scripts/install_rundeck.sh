#!/bin/bash

wget http://download.rundeck.org/deb/rundeck-$3-GA.deb -P /tmp
sudo apt-get -y install openjdk-6-jre
sudo dpkg -i /tmp/rundeck-$3-GA.deb
sudo rm -rf /tmp/rundeck/
if [[ $1 == "yes" ]]; then
  ip=`curl http://icanhazip.com`
else
  ip=`ifconfig $2 |grep "inet addr" |awk '{print $2}' |cut -d ':' -f 2`
fi
sudo sed -i s,localhost,$ip,g /etc/rundeck/framework.properties
sudo sed -i s,localhost,$ip,g /etc/rundeck/rundeck-config.properties
hostname=`hostname`
sudo echo "$ip $hostname" | sudo tee -a /etc/hosts
sudo sed -i s,"/var/lib/rundeck:/bin/false","/var/lib/rundeck:/bin/bash",g /etc/passwd
sudo chown rundeck. /var/lib/rundeck
