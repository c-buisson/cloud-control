#!/bin/bash

sudo apt-get -y install qemu-utils cloud-utils kvm libvirt-bin
sudo mkdir -p "$1"/{kvm_guests,lib,templates,lists,sources/{iso,cloud_images}}
echo "Add rundeck user to libvirtd and kvm groups"
sudo adduser rundeck libvirtd && sudo adduser rundeck kvm
kvm_guests=$(sudo virsh list)
if [[ -z "$kvm_guests" ]]; then
  echo "Restart libvirtd..."
  sudo systemctl restart libvirt-bin
fi

if [[ $2 == "yes" ]];then
  domain=$(cat /etc/resolvconf/resolv.conf.d/{head,base} |grep -w "search local")
  localhost=$(cat /etc/resolvconf/resolv.conf.d/{head,base} |grep -w "nameserver 127.0.0.1")
  if [[ -z "$domain" ]];then
    base=$(cat /etc/resolvconf/resolv.conf.d/base)
    sudo echo -e "search local\ndomain local\n$base" |sudo tee /etc/resolvconf/resolv.conf.d/base
  fi
  if [[ -z "$localhost" ]];then
    head=$(cat /etc/resolvconf/resolv.conf.d/head)
    sudo echo -e "nameserver 127.0.0.1\n$head" |sudo tee /etc/resolvconf/resolv.conf.d/head
  fi
  sudo resolvconf -u
fi

# Restart Rundeck
systemctl restart rundeckd
scripts/check_url.sh url http://"$3":4440 60
grep -q "export LIBVIRT_DEFAULT_URI=qemu:///system" /etc/environment || echo "export LIBVIRT_DEFAULT_URI=qemu:///system" | sudo tee -a /etc/environment
