#!/bin/bash

txtbold=$(tput bold)

case "$1" in
  "kvm-control" )
    project=$(sudo su - rundeck -c "rd projects list |grep $1")
    if [[ -z "$project" ]]; then
      echo -e "$txtboldCreating $1 project and jobs!\n"
      sudo su rundeck -c "rd projects create -p kvm-control"
      sudo su rundeck -c "rd jobs load -r -f $2/rundeck_jobs.xml -p kvm-control"
    else
      echo -e "$1 project and jobs already created!\n"
    fi
  ;;
  "kvm-control_with-Chef" )
    project=$(sudo su - rundeck -c "rd projects list |grep $1")
    if [[ -z "$project" ]]; then
      echo -e "$txtboldCreating $1 project and jobs!\n"
      sudo su rundeck -c "rd projects create -p kvm-control_with-Chef -- --resources.source.2.config.url=http://localhost:9980 --resources.source.2.type=url --resources.source.2.config.timeout=60 --resources.source.2.config.cache=false"
      sudo su rundeck -c "rd jobs load -r -f $2/chef-rundeck_jobs.xml -p kvm-control_with-Chef"
    else
      echo -e "$1 project and jobs already created!\n"
    fi
  ;;
  "docker-control" )
    project=$(sudo su - rundeck -c "rd projects list |grep $1")
    if [[ -z "$project" ]]; then
      echo -e "$txtboldCreating $1 project and jobs!\n"
      sudo su rundeck -c "rd projects create -p docker-control"
      sudo su rundeck -c "rd jobs load -r -f $2/rundeck_jobs.xml -p docker-control"
    else
      echo -e "$1 project and jobs already created!\n"
    fi
  ;;
  "chef_server-control" )
    project=$(sudo su - rundeck -c "rd projects list |grep $1")
    if [[ -z "$project" ]]; then
      echo -e "$txtboldCreating $1 project and jobs!\n"
      sudo su rundeck -c "rd projects create -p chef_server-control"
      sudo su rundeck -c "rd jobs load -r -f $2/rundeck_jobs-chef.xml -p chef_server-control"
    else
      echo -e "$1 project and jobs already created!\n"
    fi
  ;;
esac
