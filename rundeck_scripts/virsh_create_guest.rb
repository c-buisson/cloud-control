#!/usr/bin/env ruby

env=File.expand_path("../../ENV", __FILE__)
guest=ARGV[0]
eval File.read(env)

puts "Creating guest #{guest}...".cyan.bold
system("virsh create #{GUEST}/#{guest}.xml") or raise "The KVM instance didn't spawn..."

system("virsh define #{GUEST}/#{guest}.xml") or raise "Couldn't define that instance..."

puts "Check if #{guest} is running in virsh:"
system("virsh list --all |grep #{guest}")

puts ""
vnc=`grep vnc #{GUEST}/#{guest}.xml |awk '{print $3}' |cut -d '=' -f2 |cut -d "'" -f2`
puts "You can VNC to that server at: " + "0.0.0.0:#{vnc}".bold
