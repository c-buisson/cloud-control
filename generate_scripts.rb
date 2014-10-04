#!/usr/bin/ruby
require 'erb'

backend=ARGV[0]
start_ip=ARGV[1]
end_ip=ARGV[2]
gateway_ip=ARGV[3]
data_folder=ARGV[4]
mysql_password=ARGV[5]

#Generate ENV file
template = ERB.new(File.read("templates/ENV.erb"))
xml_content = template.result(binding)
File.open("#{data_folder}/ENV", "w") do |file|
  file.puts xml_content
end

#Generate lib files
lib_files = ["generate_static_ip", "vm_list"]
lib_files.each do |file|
  template = ERB.new(File.read("templates/#{file}.erb"))
  xml_content = template.result(binding)
  File.open("#{data_folder}/lib/#{file}.rb", "w") do |file|
    file.puts xml_content
  end
end

#Generate misc files
misc_files = ["rundeck_jobs.xml", "get_images.rb"]
misc_files.each do |misc|
  template = ERB.new(File.read("templates/#{misc}.erb"))
  xml_content = template.result(binding)
  File.open("#{data_folder}/#{misc}", "w") do |file|
    file.puts xml_content
  end
end

system("sudo su rundeck -c 'rd-project -p cloud-control -a create'")
system("sudo su rundeck -c 'rd-jobs load -r -f #{data_folder}/rundeck_jobs.xml -p cloud-control'")

#Generate user-data template file
var = "<%= ip %>"
template = ERB.new(File.read("templates/TEMPLATE-user-data.erb"))
xml_content = template.result(binding)
File.open("#{data_folder}/templates/TEMPLATE-user-data.erb", "w") do |file|
  file.puts xml_content
end

system("sudo cp templates/TEMPLATE.xml.erb #{data_folder}/templates/")
system("sudo cp templates/TEMPLATE-user-data-nat.erb #{data_folder}/templates/")
system("sudo chown -R rundeck. #{data_folder}")

puts "\nAll the scripts were generated!\n Cloud-Control folder location: #{data_folder}\n Backend: #{backend}\n Ip Range: #{start_ip} to #{end_ip}"

if backend == "mysql"
  begin
    require 'mysql2'
    client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => mysql_password)
    client.query "CREATE DATABASE IF NOT EXISTS cloud_control CHARACTER SET utf8 COLLATE utf8_general_ci"
    client.query "CREATE TABLE IF NOT EXISTS cloud_control.guests \
      (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(25), ip VARCHAR(17), vnc_port INT, network_type VARCHAR(8))"
  rescue Mysql2::Error => e
    puts e.error
  end
  puts "\nDatabase \"cloud_control\" created!"
elsif backend == "postgres"
  begin
    system("createdb -p 5432 -O pguser -U pguser -E UTF8 cloud_control")
    require 'pg'
    conn = PG::Connection.open(:dbname => "cloud_control", :user => "pguser")
    conn.exec_params('CREATE TABLE IF NOT EXISTS guests (
      id serial PRIMARY KEY, name varchar(25) NOT NULL, ip varchar(17) NOT NULL, vnc_port int, network_type varchar(8))')
  rescue PG::Error => e
    puts e.error
  end
  puts "\nDatabase \"cloud_control\" created!"
end
