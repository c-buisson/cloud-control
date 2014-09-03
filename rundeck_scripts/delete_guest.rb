#!/usr/bin/env ruby

env=File.expand_path("../../ENV", __FILE__)
guest=ARGV[0]
eval File.read(env)

puts "Check is instance is running..."
system("virsh list --all |grep #{guest}")

puts ""
puts "virsh destroy #{guest.red.bold}"
system("virsh destroy #{guest}")

puts""
puts "virsh undefine #{guest.red.bold}"
system("virsh undefine #{guest}")

if File.exist?("#{USER_DATA}/#{guest}-user-data.erb")
  ip=`cat #{USER_DATA}/#{guest}-user-data.erb |grep address |awk '{printf "%s", $2'}`

  tmp = Tempfile.new("extract")
  File.open(IP_FILE, 'r').each { |l| tmp << l unless l.chomp == ip }
  tmp.close
  FileUtils.mv(tmp.path, IP_FILE)
  File.chmod(0664, IP_FILE)

  puts "#{guest}'s IP address (" + ip.chomp.bold + ") was released"
else
  puts "No user-data for that guest, no static IP to release\n"
end

puts "removing folder: " + "#{GUEST}/\n".red
FileUtils.rm_rf(GUEST)

puts "Instance destroyed and files removed"
puts "Carry on..."
