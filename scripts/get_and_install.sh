#!/bin/bash

txtbold=$(tput bold)
txtreset=$(tput sgr0)

case "$1" in
  "rundeck-cli" )
    file=$(ls /etc/apt/sources.list.d/rundeck-cli.list 2>/dev/null)
    if [[ -z "$file" ]]; then
      echo -e "$txtbold Downloading $1!$txtreset\n"
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
    file=$(ls post_install/rundeck-"$2"-GA.deb 2>/dev/null)
    if [[ -z "$file" ]]; then
      echo -e "$txtbold Downloading $1!$txtreset\n"
      wget http://download.rundeck.org/deb/rundeck-"$2"-GA.deb -P post_install/
      dpkg -i post_install/rundeck-"$2"-GA.deb
      rm -rf /tmp/rundeck/
      cp /etc/rundeck/rundeck-config.properties /etc/rundeck/rundeck-config.properties.backup
      cp /etc/rundeck/framework.properties /etc/rundeck/framework.properties.backup
      chown $SUDO_USER. post_install/rundeck-"$2"-GA.deb
    else
      echo -e "$1 is already on this server!\n"
    fi
  ;;
esac
