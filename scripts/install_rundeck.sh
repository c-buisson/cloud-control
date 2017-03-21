#!/bin/bash

# Get source for Rundeck-CLI
scripts/get_and_install.sh rundeck-cli

# Get Rundeck deb and install
apt-get -y install openjdk-8-jre rundeck-cli
scripts/get_and_install.sh rundeck $2
cp /etc/rundeck/rundeck-config.properties.backup /etc/rundeck/rundeck-config.properties
cp /etc/rundeck/framework.properties.backup /etc/rundeck/framework.properties

# Install database
if [[ $3 == "mysql" ]]; then
  echo "mysql-server-5.7 mysql-server/root_password password $4
  mysql-server-5.7 mysql-server/root_password seen true
  mysql-server-5.7 mysql-server/root_password_again password $4
  mysql-server-5.7 mysql-server/root_password_again seen true
  " | sudo debconf-set-selections
  export DEBIAN_FRONTEND=noninteractive
  apt-get install -q -y mysql-server mysql-client libmysqlclient-dev
  # Setup rundeckdb
  scripts/get_and_install.sh "mysql-connector"
  mysql -u root -p$4 -e "create database rundeckdb"
  mysql -u root -p$4 -e "grant ALL on rundeckdb.* to 'rduser'@'localhost' identified by 'rdpasswd';"
  sed -i "s,jdbc:h2:file:/var/lib/rundeck/data/rundeckdb;MVCC=true,jdbc:mysql://localhost/rundeckdb?autoReconnect=true,g" /etc/rundeck/rundeck-config.properties
  echo -e "dataSource.username=rduser\ndataSource.password=rdpasswd" >> /etc/rundeck/rundeck-config.properties
elif [[ $3 == "postgres" ]]; then
  apt-get -y install postgresql libpq-dev
  su - postgres -c "createuser pguser -s"
  echo -e "local all postgres peer\nlocal all pguser trust\nlocal all all peer\nhost all all 127.0.0.1/32 md5" | sudo tee /etc/postgresql/9.5/main/pg_hba.conf
  systemctl restart postgresql
else
  echo "Backend: $3 not supported!"
  exit 1
fi

# Configure Rundeck
sed -i s,localhost,$1,g /etc/rundeck/framework.properties
sed -i "s,grails.serverURL=http://localhost:4440,grails.serverURL=http://$1:4440,g" /etc/rundeck/rundeck-config.properties
hostname=`hostname`
grep -q "$1 $hostname" /etc/hosts || echo "$1 $hostname" | sudo tee -a /etc/hosts
sed -i s,"/var/lib/rundeck:/bin/false","/var/lib/rundeck:/bin/bash",g /etc/passwd
chown rundeck. /var/lib/rundeck
ls /var/lib/rundeck/.ssh || sudo su rundeck -c "echo -e \"\n\" | ssh-keygen -t rsa -N \"\""
mkdir /var/lib/rundeck/.rd
echo -e "export RD_URL=http://$1:4440\nexport RD_USER=admin\nexport RD_PASSWORD=admin" > /var/lib/rundeck/.rd/rd.conf
chown -R rundeck. /var/lib/rundeck/.rd
echo "rundeck ALL=NOPASSWD: /bin/systemctl reload bind9" > /etc/sudoers.d/rundeck
chmod 440 /etc/sudoers.d/rundeck
rundeck_url=`sudo cat /etc/rundeck/framework.properties |grep framework.server.url |awk '{print $3}'`.chomp
systemctl enable rundeckd
systemctl restart rundeckd
scripts/check_url.sh http://$1:4440 60
