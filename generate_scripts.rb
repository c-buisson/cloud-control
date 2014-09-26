#!/usr/bin/ruby
require 'erb'

backend=ARGV[0]
start_ip=ARGV[1]
end_ip=ARGV[2]
gateway_ip=ARGV[3]
mysql_password=ARGV[4]
pwd=`/bin/pwd`

scripts=["delete_guest", "generate_static_ip", "generate_xml"]

#Generate ENV file
template = ERB.new(File.read("templates/ENV.erb"))
xml_content = template.result(binding)
File.open("ENV", "w") do |file|
  file.puts xml_content
end

#Generate user-data template file
var = "<%= ip %>"
template = ERB.new(File.read("templates/TEMPLATE-user-data.erb"))
xml_content = template.result(binding)
File.open("templates/TEMPLATE-user-data.erb", "w") do |file|
  file.puts xml_content
end

guest=""
eval File.read("ENV")
#Generate files from ERB
scripts.each do |s|
  template = ERB.new(File.read("templates/"+s+".erb"))
  xml_content = template.result(binding)
  File.open("rundeck_scripts/"+s+".rb", "w") do |file|
    file.puts xml_content
  end
  system("chmod 775 \"rundeck_scripts/\"#{s}\".rb\"")
end

puts "\nAll the scripts were generated!\n Backend: #{backend}\n Ip Range: #{start_ip} to #{end_ip}"

if backend == "mysql"
  begin
    require 'mysql2'
    client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => mysql_password)
    client.query "CREATE DATABASE IF NOT EXISTS cloud_control CHARACTER SET utf8 COLLATE utf8_general_ci"
    client.query "CREATE TABLE IF NOT EXISTS cloud_control.guests \
      (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(25), ip VARCHAR(17))"
  rescue Mysql2::Error => e
    puts e.error
  end
puts "\nDatabase \"cloudcontrol\" created!"
end
