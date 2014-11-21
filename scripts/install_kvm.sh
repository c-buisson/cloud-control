#!/bin/bash

sudo apt-get -y install qemu-utils cloud-utils kvm libvirt-bin
sudo mkdir -p $1/{kvm_guests,lib,templates,lists,sources/{iso,cloud_images}}
sudo cp kvm/lib/* $1/lib
echo "Add rundeck user to libvirtd and kvm groups"
sudo adduser rundeck libvirtd && sudo adduser rundeck kvm
kvm_guests=`sudo virsh list`
if [[ -z "$kvm_guests" ]]; then
  echo "Restart libvirtd..."
  sudo service libvirt-bin restart
fi

if [[ $2 == "mysql" ]]; then
  echo "mysql-server-5.5 mysql-server/root_password password $3
  mysql-server-5.5 mysql-server/root_password seen true
  mysql-server-5.5 mysql-server/root_password_again password $3
  mysql-server-5.5 mysql-server/root_password_again seen true
  " | sudo debconf-set-selections
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get install -q -y mysql-server mysql-client libmysqlclient-dev
elif [[ $2 == "postgres" ]]; then
  sudo apt-get -y install postgresql libpq-dev
  sudo su - postgres -c "createuser pguser -s"
  echo -e "local all postgres peer\nlocal all pguser trust\nlocal all all peer\nhost all all 127.0.0.1/32 md5" | sudo tee /etc/postgresql/9.3/main/pg_hba.conf
  sudo service postgresql restart
else
  echo "Backend: $2 not supported!"
  exit 1
fi
