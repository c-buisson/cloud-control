#!/bin/bash
chef_present=$(sudo docker ps -a |grep $1)
chef_up=$(sudo docker ps |grep $1)
set -e
if [[ -z "$chef_present" ]]; then
  echo -e "Downloading container and start $1\n"
  sudo mkdir -p $3/$1/logs
  docker pull cbuisson/chef-server:v2.2
  sudo docker run --privileged -e CONTAINER_NAME=$1 -e CHEF_PORT=$2 --name $1 -d -v $3/$1/logs/chef-logs:/var/log -v $3/$1/logs/install-chef-out:/root -p $2:$2 cbuisson/chef-server:v2.2
  docker_ip=$(sudo docker inspect -f '{{.NetworkSettings.IPAddress }}' $1)
  grep -q "$docker_ip $1" /etc/hosts || echo "$docker_ip $1" | sudo tee -a /etc/hosts
  sudo scripts/check_url.sh https://$1:$2/knife_admin_key.tar.gz 600
  sudo curl -o $3/$1/knife_admin_key.tar.gz -Ok https://$1:$2/knife_admin_key.tar.gz
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y chef
  knife_keys=( /var/lib/rundeck ~ )
  for i in "${knife_keys[@]}"
    do
    mkdir -p $i/.chef
    cat > $i/.chef/config.rb << EOL
log_level                :info
log_location             STDOUT
cache_type               'BasicFile'
node_name                'admin'
client_key               '$i/.chef/admin.pem'
chef_server_url          'https://$1:$2/organizations/my_org'
EOL
    sudo tar -zxf $3/$1/knife_admin_key.tar.gz -C $i/.chef/
  done
  knife ssl fetch
  knife user list
  sudo su - rundeck -c "knife ssl fetch && knife user list"
  sudo chown rundeck. -R $3/$1
  echo -e "\n\e[1mCreating knife keys for rundeck and $SUDO_USER users!\e[0m"
  sudo chown rundeck. -R /var/lib/rundeck/.chef/
  sudo chown $SUDO_USER. -R ~/.chef/
elif [[ -z "$chef_up" ]]; then
  echo -e "Starting $1 container\n"
  sudo docker start $1
else
  echo -e "\nThere is already a Docker container named: $1\nRemove it first and re-run that script if you want a new container!\n"
fi
