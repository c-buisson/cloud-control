#!/bin/bash

apt-get -y install qemu-utils cloud-utils kvm libvirt-bin libvirt-dev
gem install ruby-libvirt --no-ri --no-rdoc --conservative
mkdir -p "$1"/{kvm_guests,lib,templates,lists,sources/{iso,cloud_images}}
grep -q "export LIBVIRT_DEFAULT_URI=qemu:///system" /etc/environment || echo "export LIBVIRT_DEFAULT_URI=qemu:///system" | tee -a /etc/environment
# Get Libvirt group name from file, it can change between Ubuntu versions.
libvirt_group=$(grep unix_sock_group /etc/libvirt/libvirtd.conf |awk '{print $3}' |cut -d '"' -f 2)
echo "Add rundeck user to $libvirt_group and kvm groups"
adduser rundeck $libvirt_group && adduser rundeck kvm
kvm_guests=$(virsh list)
if [[ -z "$kvm_guests" ]]; then
  echo "Restart libvirtd..."
  systemctl restart libvirt-bin
fi

if [[ $2 == "yes" ]];then
  domain=$(cat /etc/resolvconf/resolv.conf.d/{head,base} |grep -w "search local")
  localhost=$(cat /etc/resolvconf/resolv.conf.d/{head,base} |grep -w "nameserver 127.0.0.1")
  if [[ -z "$domain" ]];then
    base=$(cat /etc/resolvconf/resolv.conf.d/base)
    echo -e "search local\ndomain local\n$base" |tee /etc/resolvconf/resolv.conf.d/base
  fi
  if [[ -z "$localhost" ]];then
    head=$(cat /etc/resolvconf/resolv.conf.d/head)
    echo -e "nameserver 127.0.0.1\n$head" |tee /etc/resolvconf/resolv.conf.d/head
  fi
  resolvconf -u
fi

# Restart Rundeck only once to apply new permissions (added rundeck to libvirtd and kvm groups)
scripts/restart_rundeck.sh $3 "kvm"
