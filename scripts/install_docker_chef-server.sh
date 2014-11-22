#!/bin/bash
sudo mkdir -p $3/$1/logs
chef_up=`sudo docker ps -a |grep -v CONTAINER |grep $1`
set -e
if [[ -z "$chef_up" ]]; then
  sudo docker run --privileged -e CHEF_PORT=$2 --name $1 -d -v $3/$1/logs/chef-logs:/var/log -v $3/$1/logs/install-chef-out:/root -p $2:$2 cbuisson/chef-server
else
  echo -e "\nThere is already a Docker container named: $1\nRemove it first and re-run that script if you want a new container!\n"
fi
sudo scripts/check_url.sh https://$4:$2/knife_admin_key.tar.gz 300
sudo curl -o $3/$1/knife_admin_key.tar.gz -Ok https://$4:$2/knife_admin_key.tar.gz
sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y ruby1.9.1-dev chef
knife_keys=( /var/lib/rundeck ~ )
for i in "${knife_keys[@]}"
  do
  mkdir -p $i/.chef
  cat > $i/.chef/knife.rb << EOL
log_level                :info
log_location             STDOUT
cache_type               'BasicFile'
node_name                'admin'
client_key               '$i/.chef/admin.pem'
validation_client_name   'chef-validator'
validation_key           '$i/.chef/chef-validator.pem'
chef_server_url          'https://$4:$2'
EOL
  sudo tar -zxf $3/$1/knife_admin_key.tar.gz -C $i/.chef/
done
sudo chown rundeck. -R $3/$1
echo -e "\n\e[1mCreating knife keys for rundeck and $SUDO_USER users!\e[0m"
sudo chown rundeck. -R /var/lib/rundeck/.chef/
sudo chown $SUDO_USER. -R ~/.chef/
