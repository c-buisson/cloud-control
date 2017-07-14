#!/bin/bash

txtbold=$(tput bold)

case "$1" in
  "rundeck-cli" )
    file=$(for i in /etc/apt/sources.list.d/*; do echo "$i" |grep rundeck-cli.list; done)
    if [[ -z "$file" ]]; then
      echo -e "$txtbold Downloading $1!\n"
      echo "deb https://dl.bintray.com/rundeck/rundeck-deb /" | tee -a /etc/apt/sources.list.d/rundeck-cli.list
      curl "https://bintray.com/user/downloadSubjectPublicKey?username=bintray" > /tmp/bintray.gpg.key
      apt-key add - < /tmp/bintray.gpg.key
      apt-get -y install apt-transport-https
      apt-get -y update
    else
      echo -e "$1 is already on this server!\n"
    fi
  ;;
  "rundeck" )
    file=$(for i in *; do echo "$i" |grep rundeck-"$2"-GA.deb; done)
    if [[ -z "$file" ]]; then
      echo -e "$txtbold Downloading $1!\n"
      wget http://download.rundeck.org/deb/rundeck-"$2"-GA.deb
      dpkg -i rundeck-"$2"-GA.deb
      rm -rf /tmp/rundeck/
      cp /etc/rundeck/rundeck-config.properties /etc/rundeck/rundeck-config.properties.backup
      cp /etc/rundeck/framework.properties /etc/rundeck/framework.properties.backup
    else
      echo -e "$1 is already on this server!\n"
    fi
  ;;
esac
