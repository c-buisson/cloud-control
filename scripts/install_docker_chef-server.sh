#!/bin/bash
txtbold=$(tput bold)
chef_present=$(sudo docker ps -a |grep "$1")
chef_up=$(sudo docker ps |grep "$1")
chef_docker_ip=$4
set -e
if [[ -z "$chef_present" ]]; then
  echo -e "$txtboldDownloading container and start $1\n"
  sudo mkdir -p "$3"/"$1"/logs
  # Get the chef-server Docker image and run it
  docker pull cbuisson/chef-server:v2.3
  sudo docker run --net mc_net --ip $chef_docker_ip --privileged -e CONTAINER_NAME="$1" -e SSL_PORT="$2" --name "$1" -d -v "$3"/"$1"/logs/chef-logs:/var/log -v "$3"/"$1"/logs/install-chef-out:/root -p "$2":"$2" cbuisson/chef-server:v2.3
  # Get the container's IP and add it to /etc/hosts
  grep -q "$chef_docker_ip $1" /etc/hosts || echo "$chef_docker_ip $1" | sudo tee -a /etc/hosts
  # Check the Chef is running
  sudo scripts/check_url.sh url https://"$1":"$2" 900
  # Check if the archive containg the knife key is accessible and then download it
  sudo scripts/check_url.sh file https://"$1":"$2"/knife_admin_key.tar.gz 2500 900
  sudo curl -o "$3"/"$1"/knife_admin_key.tar.gz -Ok https://"$1":"$2"/knife_admin_key.tar.gz
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y chef
  # Create two .chef folders, one for the current user and one for the rundeck user
  knife_keys=( /var/lib/rundeck ~ )
  for i in "${knife_keys[@]}"
    do
    mkdir -p "$i"/.chef
    cat > "$i"/.chef/config.rb << EOL
log_level                :info
log_location             STDOUT
cache_type               'BasicFile'
node_name                'admin'
client_key               '$i/.chef/admin.pem'
chef_server_url          'https://$1:$2/organizations/my_org'
EOL
    sudo tar -zxf "$3"/"$1"/knife_admin_key.tar.gz -C "$i"/.chef/
  done
  sudo chown -R rundeck. /var/lib/rundeck/.chef/
  knife ssl fetch
  knife user list
  sudo su - rundeck -c "knife ssl fetch && knife user list"
  sudo chown rundeck. -R "$3"/"$1"
  echo -e "\n\eCreating knife keys for rundeck and $SUDO_USER users!\e"
  sudo chown rundeck. -R /var/lib/rundeck/.chef/
  sudo chown "$SUDO_USER". -R ~/.chef/
elif [[ -z "$chef_up" ]]; then
  echo -e "Starting $1 container\n"
  sudo docker start "$1"
else
  echo -e "\nThere is already a Docker container named: $1\nRemove it first and re-run that script if you want a new container!\n"
fi
