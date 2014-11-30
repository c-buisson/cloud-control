#!/usr/bin/ruby

def setup_kvm_db(backend, database_name, db_kvm_table, mysql_password)
  if backend == "mysql"
    begin
      bundle_install "mysql2"
      Gem.clear_paths
      require 'mysql2'
      client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => mysql_password)
      client.query "CREATE DATABASE IF NOT EXISTS #{database_name} CHARACTER SET utf8 COLLATE utf8_general_ci"
      client.query "CREATE TABLE IF NOT EXISTS #{database_name}.#{db_kvm_table} \
        (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(25), ip VARCHAR(17), vnc_port INT, mac_address VARCHAR(17), network_type VARCHAR(8), chef_installed VARCHAR(3))"
    rescue Mysql2::Error => e
      puts e.error
    end
    puts "\nDatabase \"#{database_name}\" created!"
  elsif backend == "postgres"
    begin
      system("createdb -p 5432 -O pguser -U pguser -E UTF8 #{database_name}")
      bundle_install "pg"
      require 'pg'
      conn = PG::Connection.open(:dbname => "#{database_name}", :user => "pguser")
      conn.exec_params("CREATE TABLE IF NOT EXISTS #{db_kvm_table} (
        id serial PRIMARY KEY, name varchar(25) NOT NULL, ip varchar(17) NOT NULL, vnc_port int, mac_address(17), network_type varchar(8), chef_installed VARCHAR(3))")
    rescue PG::Error => e
      puts e.error
    end
    puts "\nDatabase \"#{database_name}\" created!"
  end
end
