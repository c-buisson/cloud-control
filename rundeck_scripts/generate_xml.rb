#!/usr/bin/env ruby

(0..3).each do |arguments|
  if ARGV[arguments].nil?
    puts "ARGV#{arguments} is empty"
    puts "Usage: generate_xml.rb $name $ram $cores $source"
    exit 1
  end
end

env=File.expand_path("../../ENV", __FILE__)
guest=ARGV[0]
eval File.read(env)

#Access def.rb library file
require_relative "#{RUNDECK_SCRIPTS}/def.rb"

#Checking if there is at least one guest on the system
if Dir.glob("#{KVM_DIR}/*").empty?
  new_vnc_port="5901"
  new_mac_address="52:54:aa:" + (1..3).map{"%0.2X"%rand(256)}.join(":").downcase
  puts "First guest on that server!\n Assigning VNC port: #{new_vnc_port} and mac_address: #{new_mac_address}".bold
else
  #Calling the method generate_value for a new vnc_port and a new mac_address
  vnc_ports_use = generate_value "vnc", 59, "'", "vnc_ports_use"
  mac_address_use = generate_value "mac address", ":", "'/>", "mac_address_use"

  #Found the higher VNC port number and add 1 to it.
  new_vnc_port=vnc_ports_use.sort.last.to_i+1
  #Generates a random MAC address
  new_mac_address="52:54:aa:" + (1..3).map{"%0.2X"%rand(256)}.join(":").downcase
  #Test is the generated mac is already in use by a guest.
  mac_address_use.each do |mac|
    if mac == new_mac_address
      puts "The generated mac_address is already assigned to another KVM guest...".red.bold
      exit 1
    end
  end
end

#Creating sub-directories
Dir.mkdir(GUEST) unless Dir.exist?(GUEST)
Dir.mkdir(SNAPSHOTS) unless Dir.exist?(SNAPSHOTS)
Dir.mkdir(KVM_GUEST_IMAGE) unless Dir.exist?(KVM_GUEST_IMAGE)

#Guessing which type of source we need to create an XML for
if ARGV[3].include?("iso")
  puts "Generating XML file for an ISO".cyan.bold
  type="iso"
elsif ARGV[3].include?("origin")
  puts "Generating XML file for a Cloud Image".cyan.bold
  type="cloud"

  #generating interface file with a static IP
  Dir.mkdir(USER_DATA) unless Dir.exist?(USER_DATA)
  require_relative "#{RUNDECK_SCRIPTS}/generate_static_ip.rb"
  generate_ip ARGV[0]

  #generating user-data file to setup the guest hostname
  system("#{CLOUD_UTILS}/bin/cloud-localds -H #{ARGV[0]} #{USER_DATA}/user-data-#{ARGV[0]}.img #{USER_DATA}/#{ARGV[0]}-user-data.erb") or raise "Couldn't generate User Date image!".red
  user_data="user-data-#{ARGV[0]}.img"
else
  puts "Wrong source type! Must be 'iso' or 'cloud'".red
  puts "Source: #{ARGV[3]}"
  exit 1
end

#Collecting data from Rundeck
name=ARGV[0]
uuid=SecureRandom.uuid
ram=ARGV[1].to_i*1024
cores=ARGV[2].to_i
source=ARGV[3]
mac_address=new_mac_address
vnc_port=new_vnc_port

#Generate template for the new guest
template = ERB.new(File.read("#{TEMPLATES}/TEMPLATE.xml.erb"))
xml_content = template.result(binding)
File.open(XML, "w") do |file|
  file.puts xml_content
end

puts "New XML file created at: " + XML.underline
