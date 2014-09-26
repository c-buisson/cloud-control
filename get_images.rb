#!/usr/bin/env ruby

env=File.expand_path("../ENV", __FILE__)
guest=""
eval File.read(env)

if ARGV[0].nil?
  puts "This script will download and place any ISO or Cloud Image to the correct location"
  puts "For Ubuntu ISO, go to: http://mirror.anl.gov/pub/ubuntu-iso/DVDs/ubuntu/"
  puts "For Ubuntu CLoud Image, go to: https://cloud-images.ubuntu.com/"
  puts "\nUsage: get_images.rb URL"
  exit 1
end

path=ARGV[0]

if path.include? "iso"
  system("wget #{path} -P #{ISO}") or raise "Error while downloading that ISO. Wrong URL maybe?"
elsif path.include? "img"
  system("wget #{path} -P #{CLOUD_IMAGES}") or raise "Error while downloading that Cloud Image. Wrong URL maybe?"
else
  puts "Doesn't support this type of source"
  puts "Must be ISO or Cloud Image"
exit 1
end
