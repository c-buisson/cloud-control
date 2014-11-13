#!/usr/bin/ruby
require 'erb'
vars=File.expand_path("../../vars", __FILE__)
eval File.read(vars)

puts "Updating knife.rb"
system("sudo cp /var/lib/rundeck/.chef/knife.rb  ~/.chef/")
system("sudo chown $SUDO_USER. -R ~/.chef/")
puts "Got new knife.rb from: /var/lib/rundeck/.chef/knife.rb!\n"
