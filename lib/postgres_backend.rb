#!/usr/bin/ruby

def add_guest(name, ip, vnc_port, network_type)
  begin
    conn = PG::Connection.open(:dbname => "cloud_control", :user => "pguser")
    conn.exec_params "INSERT INTO guests (name, ip, vnc_port, network_type) VALUES ('#{name}', '#{ip}', '#{vnc_port}', '#{network_type}')"
  rescue PG::Error => e
    puts e.error
  end
end

def get_ips_list
  begin
    ip_in_use=[]
    conn = PG::Connection.open(:dbname => "cloud_control", :user => "pguser")
    conn.exec_params("SELECT * FROM guests").each do |row|
      ip_in_use << row["ip"]
    end
  rescue PG::Error => e
    puts e.error
  end
return ip_in_use
end

def remove_guest(name)
  begin
    conn = PG::Connection.open(:dbname => "cloud_control", :user => "pguser")
    conn.exec_params "DELETE FROM guests WHERE name = '#{name}'"
  rescue PG::Error => e
    puts e.error
  end
end

def guest_ip(name)
  begin
    ip = ""
    conn = PG::Connection.open(:dbname => "cloud_control", :user => "pguser")
    conn.exec_params("SELECT * FROM guests WHERE name = '#{name}'").each do |x|
      ip = x["ip"]
    end
  rescue PG::Error => e
    puts e.error
  end
return ip
end
