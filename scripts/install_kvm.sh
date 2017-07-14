#!/bin/bash

apt-get -y install qemu-utils cloud-utils kvm libvirt-bin libvirt-dev
gem install ruby-libvirt --no-ri --no-rdoc --conservative
mkdir -p "$1"/{kvm_guests,lib,templates,lists,sources/{iso,cloud_images}}
echo "Add rundeck user to libvirtd and kvm groups"
adduser rundeck libvirtd && adduser rundeck kvm
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
if [ ! -f rundeck_restarted_kvm ]; then
  systemctl restart rundeckd
  scripts/check_url.sh url http://"$3":4440 60
  grep -q "export LIBVIRT_DEFAULT_URI=qemu:///system" /etc/environment || echo "export LIBVIRT_DEFAULT_URI=qemu:///system" | tee -a /etc/environment
  touch rundeck_restarted_kvm
fi
