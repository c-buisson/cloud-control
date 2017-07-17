#!/bin/bash

txtbold=$(tput bold)
txtreset=$(tput sgr0)

# Get source for Rundeck-CLI
scripts/get_and_install.sh rundeck-cli

# Get Rundeck deb and install
apt-get -y --allow-unauthenticated install openjdk-8-jre rundeck-cli
scripts/get_and_install.sh rundeck "$2"
cp /etc/rundeck/rundeck-config.properties.backup /etc/rundeck/rundeck-config.properties
cp /etc/rundeck/framework.properties.backup /etc/rundeck/framework.properties

# Install database
if [[ $3 == "mysql" ]]; then
  mysql_version=`apt-cache policy mysql-server |grep Candidate |grep -o "[0-9]\.[0-9]" |head -n 1`
  echo "mysql-server-$mysql_version mysql-server/root_password password $4
  mysql-server-$mysql_version mysql-server/root_password seen true
  mysql-server-$mysql_version mysql-server/root_password_again password $4
  mysql-server-$mysql_version mysql-server/root_password_again seen true
  " | debconf-set-selections
  export DEBIAN_FRONTEND=noninteractive
  apt-get install -q -y mysql-server mysql-client libmysqlclient-dev
  # Setup rundeckdb
  ruby scripts/setup_rundeck_db.rb $3 "rundeckdb" $4
  # Update Rundeck config files to use MySQL
  sed -i "s,jdbc:h2:file:/var/lib/rundeck/data/rundeckdb;MVCC=true,jdbc:mysql://localhost/rundeckdb?autoReconnect=true,g" /etc/rundeck/rundeck-config.properties
  echo -e "dataSource.username=rduser\ndataSource.password=rdpasswd" >> /etc/rundeck/rundeck-config.properties
elif [[ "$3" == "postgres" ]]; then
  apt-get -y install postgresql libpq-dev
  ruby scripts/setup_rundeck_db.rb $3 "rundeckdb"
  # Update Rundeck config files to use MySQL
  sed -i "s,jdbc:h2:file:/var/lib/rundeck/data/rundeckdb;MVCC=true,jdbc:postgresql://localhost/rundeckdb,g" /etc/rundeck/rundeck-config.properties
  echo -e "dataSource.driverClassName = org.postgresql.Driver\ndataSource.username=rduser\ndataSource.password=rdpasswd" >> /etc/rundeck/rundeck-config.properties
else
  echo -e "Backend: $txtbold$3$txtreset not supported!"
  exit 1
fi

# Configure Rundeck
sed -i s,localhost,"$1",g /etc/rundeck/framework.properties
sed -i "s,grails.serverURL=http://localhost:4440,grails.serverURL=http://$1:4440,g" /etc/rundeck/rundeck-config.properties
hostname=$(hostname)
grep -q "$1 $hostname" /etc/hosts || echo "$1 $hostname" | tee -a /etc/hosts
sed -i "s,/var/lib/rundeck:/bin/false,/var/lib/rundeck:/bin/bash,g" /etc/passwd
# Create rundeck user SSH keys
chown rundeck. /var/lib/rundeck
ls /var/lib/rundeck/.ssh >/dev/null 2>&1 || su rundeck -c "echo -e \"\n\" | ssh-keygen -t rsa -N \"\""
# Configure rundeck-cli for current and rundeck users
mkdir -p /var/lib/rundeck/.rd
mkdir -p ~/.rd
echo -e "export RD_URL=http://$1:4440\nexport RD_USER=admin\nexport RD_PASSWORD=admin" > /var/lib/rundeck/.rd/rd.conf
echo -e "export RD_URL=http://$1:4440\nexport RD_USER=admin\nexport RD_PASSWORD=admin" > ~/.rd/rd.conf
chown -R rundeck. /var/lib/rundeck/.rd
chown -R "$SUDO_USER". ~/.rd
# Grant Bind9 access to rundeck user 
echo "rundeck ALL=NOPASSWD: /bin/systemctl reload bind9" > /etc/sudoers.d/rundeck
chmod 440 /etc/sudoers.d/rundeck
# Start Rundeck!
systemctl enable rundeckd
scripts/restart_rundeck.sh $1
