#!/usr/bin/env ruby

def generate_ip (name)

  #Creating the 2 arrays
  ip_in_use=[]
  vm_ip_range=[]

  #IP range
  start_ip = IPAddr.new(START_IP)
  end_ip   = IPAddr.new(END_IP)

    file = File.open(IP_FILE).each do |lines|
      ip_in_use << lines.tr("\n","")
    end

  #list of IPs in use
  ip_in_use=ip_in_use.sort!

  #Generating the range of IPs in an Array
  vm_ip_range=(start_ip..end_ip).map(&:to_s)

  #Difference between rango of IPs and the IPs in use
  available= vm_ip_range - ip_in_use

  #puts "List of available IPs:"
  #puts available
  if available[0].nil?
    puts "no more IPs available! Stopping...\n".red.bold
    exit 1
  end

  puts "That new guest will have the IP: " + "#{available[0]}\n".bold
  ip = available[0]

  #Generate template for the new guest
  template = ERB.new(File.read("#{TEMPLATES}/TEMPLATE-user-data.erb"))
  interfaces = template.result(binding)
  File.open("#{USER_DATA}/#{ARGV[0]}-user-data.erb", "w") do |file|
    file.puts interfaces
  end

  File.open(IP_FILE, "a") {|f|
    f << "#{available[0]}\n"
  }
  File.chmod(0664, IP_FILE)
end
