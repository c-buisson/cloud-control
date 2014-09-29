#!/usr/bin/ruby

def add_guest(name, ip, vnc_port)
  begin
    client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => MYSQL_PASSWORD)
    client.query "INSERT INTO cloud_control.guests (name, ip, vnc_port) VALUES ('#{name}', '#{ip}', '#{vnc_port}')"
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
