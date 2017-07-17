#!/usr/bin/ruby

backend = ARGV[0]
database_name = ARGV[1]
password = ARGV[2]

if backend == "mysql"
  begin
    system("gem install mysql2 --no-ri --no-rdoc --conservative")
    Gem.clear_paths
    require 'mysql2'
    client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => password)
    client.query "CREATE DATABASE IF NOT EXISTS #{database_name} CHARACTER SET utf8 COLLATE utf8_general_ci"
    client.query "grant ALL on #{database_name}.* to 'rduser'@'localhost' identified by 'rdpasswd';"
  rescue Mysql2::Error => e
    puts e.error
  end
  puts "Database \"#{database_name}\" ready!"
elsif backend == "postgres"
  begin
    system("gem install pg --no-ri --no-rdoc --conservative")
    system("su - postgres -c \"createuser pguser -s\"")
    postgres_version=`apt-cache policy postgresql |grep Candidate |grep -o -P "[0-9]\\.[0-9]"`.chomp
    %x[/bin/bash -c 'echo -e \"local all postgres peer\nlocal all pguser trust\nlocal all rduser trust\nlocal all all peer\nhost all all 127.0.0.1/32 md5\" | tee /etc/postgresql/#{postgres_version}/main/pg_hba.conf']
    system("systemctl restart postgresql && sleep 5")
    system("createdb -p 5432 -O pguser -U pguser -E UTF8 #{database_name}")
    system("createuser -p 5432 -U pguser rduser")
    Gem.clear_paths
    require 'pg'
    conn = PG::Connection.open(:dbname => "#{database_name}", :user => "pguser")
    conn.exec_params("ALTER USER \"rduser\" WITH PASSWORD 'rdpasswd';")
    conn.exec_params("grant ALL privileges on database #{database_name} to rduser;")
  rescue PG::Error => e
    puts e.error
  end
  puts "Database \"#{database_name}\" ready!"
else
  puts "BACKEND variable must be: 'mysql' OR 'postgres'! Please update 'vars' file!"
  exit 1
end
