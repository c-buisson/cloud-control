#!/usr/bin/ruby 

if ARGV[0] == "yes"
  ip=`curl http://icanhazip.com`
else
  ip=`ifconfig #{ARGV[1]} |grep "inet addr" |awk '{print $2}' |cut -d ':' -f 2`
end

puts ip
