#!/bin/bash
txtbold=$(tput bold)
echo -e "$txtbold Fetching Knife keys\n"
# Check if the archive containg the knife key is accessible and then download it
scripts/check_url.sh file https://"$1":"$2"/knife_admin_key.tar.gz 2500 900
curl -o "$3"/"$1"/knife_admin_key.tar.gz -Ok https://"$1":"$2"/knife_admin_key.tar.gz
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
  # Extract Knife keys into .chef folders
  tar -zxf "$3"/"$1"/knife_admin_key.tar.gz -C "$i"/.chef/
done
chown -R rundeck. /var/lib/rundeck/.chef/
# Get SSL certs
knife ssl fetch
knife user list
su - rundeck -c "knife ssl fetch && knife user list"
chown rundeck. -R "$3"/"$1"
echo -e "\nCreating knife keys for rundeck and $SUDO_USER users!\n"
chown rundeck. -R /var/lib/rundeck/.chef/
chown "$SUDO_USER". -R ~/.chef/
