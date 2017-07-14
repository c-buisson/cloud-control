#!/bin/bash

txtbold=$(tput bold)

case "$1" in
  "kvm-control" )
    project=$(rd projects list |grep $1)
    if [[ -z "$project" ]]; then
      echo -e "$txtbold Creating $1 project!\n"
      rd projects create -p kvm-control -- --resources.source.2.config.url=http://localhost:9980 --resources.source.2.type=url --resources.source.2.config.timeout=60 --resources.source.2.config.cache=false
    fi
  ;;
  "kvm-control_with-Chef" )
    echo -e "Adding jobs to kvm-control!\n"
    rd jobs load -r -f $2/rundeck_jobs.xml -p kvm-control
    echo -e "Adding dedicated Chef jobs to kvm-control!\n"
    rd jobs load -r -f $2/chef-rundeck_jobs.xml -p kvm-control
  ;;
  "remove_chef_jobs" )
    jobs=$(rd jobs list -p kvm-control)
    if [[ $jobs == *"Docker"* ]]; then
      echo -e "\n$txtbold Removing unneeded Chef Docker jobs!\n"
      rd jobs purge -y -j "Docker: Delete chef-server and chef-rundeck containers" -p kvm-control
      rd jobs purge -y -j "Docker: Start chef-server and chef-rundeck containers" -p kvm-control
      rd jobs purge -y -j "Docker: Stop chef-server and chef-rundeck containers" -p kvm-control
      rd jobs purge -y -j "Docker: Restart chef-rundeck" -p kvm-control
    fi
    if [[ $jobs == *"Launch"* ]]; then
      echo -e "\n$txtbold Cleaning up \".Launch KVM guest\" job!\n"
      rd jobs purge -y -j ".Launch KVM guest" -p kvm-control
    fi
    if [[ $jobs == *"KVM: Delete guest"* ]]; then
      echo -e "\n$txtbold Cleaning up \"KVM: Delete guest\" job!\n"
      rd jobs purge -y -j "KVM: Delete guest" -p kvm-control
    fi
    if [[ $jobs == *"KVM: Delete all guests"* ]]; then
      echo -e "\n$txtbold Cleaning up \"KVM: Delete all guests\" job!\n"
      rd jobs purge -y -j "KVM: Delete all guests" -p kvm-control
    fi
    if [[ $jobs == *"4.Bootstrap guest"* ]]; then
      echo -e "\n$txtbold Cleaning up \"4.Bootstrap guest\" job!\n"
      rd jobs purge -y -j "4.Bootstrap guest" -p kvm-control
    fi
    echo -e "\n$txtbold Updating kvm-control jobs!\n"
    rd jobs load -r -f $2/rundeck_jobs.xml -p kvm-control
  ;;
  "get_first_source" )
    rd run -p kvm-control -j "Source: Add Cloud Image or ISO" -f -- -URL $2 
  ;;
  "docker-control" )
    project=$(rd projects list |grep -w $1)
    if [[ -z "$project" ]]; then
      echo -e "$txtbold Creating $1 project and jobs!\n"
      rd projects create -p docker-control
      rd jobs load -r -f $2/rundeck_jobs.xml -p docker-control
    else
      echo -e "$1 project and jobs already created!\n"
    fi
  ;;
esac
