#!/usr/bin/env ruby

env=File.expand_path("../../ENV", __FILE__)
guest=ARGV[0]
eval File.read(env)

size=ARGV[1]
source=ARGV[2]

puts "Creating image file for KVM\n".cyan.bold

#Creating sub-directories
Dir.mkdir(GUEST)
Dir.mkdir(SNAPSHOTS)
Dir.mkdir(KVM_GUEST_IMAGE)

if source.include? "iso"
  puts "That image will be blank (iso mode)\e"
  system("qemu-img create -f qcow2 #{KVM_GUEST_IMAGE}/#{guest}.img #{size}G")
elsif source.include? "img"
  puts "That image will be a Cloud image\e"
  system("qemu-img convert -O qcow2 #{CLOUD_IMAGES}/#{source} #{KVM_GUEST_IMAGE}/#{guest}.img") or raise "Couldn't create #{KVM_GUEST_IMAGE}/#{guest}.img".red
  puts "Adding diskspace to have: #{size}Gb available"
  system("qemu-img resize #{KVM_GUEST_IMAGE}/#{guest}.img +`expr #{size} - 2`G") or raise "Couldn't resize #{KVM_GUEST_IMAGE}/#{guest}.img to #{size}".red
end

puts ""
puts "New image info\n".underline
system("qemu-img info #{KVM_GUEST_IMAGE}/#{guest}.img")
puts ""
