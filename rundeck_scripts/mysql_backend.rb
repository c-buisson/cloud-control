#!/usr/bin/ruby

def create_db
  begin
    client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => MYSQL_PASSWORD)
    client.query "CREATE DATABASE IF NOT EXISTS cloud_control CHARACTER SET utf8 COLLATE utf8_general_ci"
    client.query "CREATE TABLE IF NOT EXISTS cloud_control.guests \
      (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(25), ip VARCHAR(17))"
  rescue Mysql2::Error => e
    puts e.error
  end
end

def add_guest(name, ip)
  begin
    client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => MYSQL_PASSWORD)
    client.query "INSERT INTO cloud_control.guests (name, ip) VALUES ('#{name}', '#{ip}')"
  rescue Mysql2::Error => e
    puts e.error
  end
end

def get_ips_list
  begin
    ip_in_use=[]
    client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => MYSQL_PASSWORD)
    client.query("SELECT * FROM cloud_control.guests").each do |row|
      ip_in_use << row["ip"]
    end
  rescue Mysql2::Error => e
    puts e.error
  end
return ip_in_use
end

def remove_guest(name)
  begin
    client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => MYSQL_PASSWORD)
    client.query "DELETE FROM cloud_control.guests WHERE name = '#{name}'"
  rescue Mysql2::Error => e
    puts e.error
  end
end

def guest_ip(name)
  begin
    ip = ""
    client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => MYSQL_PASSWORD)
    client.query("SELECT * FROM cloud_control.guests WHERE name = '#{name}'").each do |x|
      ip = x["ip"]
    end
  rescue Mysql2::Error => e
    puts e.error
  end
return ip
end
