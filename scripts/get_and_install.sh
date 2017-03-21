#!/bin/bash

case "$1" in
  "rundeck-cli" )
    file=$(ls /etc/apt/sources.list.d/ |grep rundeck-cli.list)
    if [[ -z "$file" ]]; then
      echo -e "Downloading $1!\n"
      echo "deb https://dl.bintray.com/rundeck/rundeck-deb /" | sudo tee -a /etc/apt/sources.list.d/rundeck-cli.list
      curl "https://bintray.com/user/downloadSubjectPublicKey?username=bintray" > /tmp/bintray.gpg.key
      apt-key add - < /tmp/bintray.gpg.key
      apt-get -y install apt-transport-https
      apt-get -y update
    else
      echo -e "$1 is already on this server!\n"
    fi
  ;;
  "rundeck" )
    file=$(ls |grep rundeck-$2-GA.deb)
    if [[ -z "$file" ]]; then
      echo -e "Downloading $1!\n"
      wget http://download.rundeck.org/deb/rundeck-$2-GA.deb
      dpkg -i rundeck-$2-GA.deb
      rm -rf /tmp/rundeck/
      cp /etc/rundeck/rundeck-config.properties /etc/rundeck/rundeck-config.properties.backup
      cp /etc/rundeck/framework.properties /etc/rundeck/framework.properties.backup
    else
      echo -e "$1 is already on this server!\n"
    fi
  ;;
  "mysql-connector" )
    file=$(ls |grep mysql-connector-java-5.1.40.tar.gz)
    if [[ -z "$file" ]]; then
      echo -e "Downloading $1!\n"
      wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz
      tar -zxf mysql-connector-java-5.1.40.tar.gz -C /tmp/
      cp /tmp/mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar /var/lib/rundeck/libext/
    else
      echo -e "$1 is already on this server!\n"
    fi
  ;;
  "chef-rundeck" )
    file=$(ls |grep ruby-ffi)
    if [[ -z "$file" ]]; then
      echo -e "Downloading ffy dependencies and chef-rundeck gem!\n"
      wget http://mirrors.kernel.org/ubuntu/pool/universe/r/ruby-ffi/ruby-ffi_1.9.10debian-1build2_amd64.deb http://security.ubuntu.com/ubuntu/pool/universe/r/ruby-ffi-yajl/ruby-ffi-yajl_2.2.3-2_amd64.deb
      sudo dpkg -i ruby-ffi*
      sudo gem install chef-rundeck
    else
      echo -e "$1 and its dependencies are already installed on this server!\n"
    fi
  ;;
esac
