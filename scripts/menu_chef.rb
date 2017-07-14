#!/usr/bin/ruby
require 'erb'

def chef_menu (ip_host)
  puts "\nDo you want to setup a Docker container with Chef server?".bold
  puts "  1. Yes".green + " - chef-server-control".bold
  puts "  2. No".green
  puts "  3. Get keys".green + " (chef-server already installed. Re-fetching the admin keys)".bold
  case gets.strip
    when "1", "y"
      system("scripts/install_docker.sh #{DOCKER_FOLDER} #{ip_host}")
      system("scripts/install_docker_chef-server.sh #{CHEF_SERVER_CONTAINER_NAME} #{CHEF_PORT} #{DOCKER_FOLDER} #{CHEF_SERVER_CONTAINER_IP}")
      chef_rundeck
      self.class.const_set(:INSTALL_CHEF, "yes")
    when "2", "n"
      self.class.const_set(:INSTALL_CHEF, "no")
      puts "Ok, moving on..."
    when "3"
      fetch_chef_keys
      self.class.const_set(:INSTALL_CHEF, "yes")
    else
      chef_menu
  end
end

def chef_rundeck
  unless `docker ps |grep chef-rundeck` != ""
    puts "Setting up chef-rundeck container".bold
    system("scripts/install_docker_chef-rundeck.sh #{CHEF_RUNDECK_CONTAINER_NAME} #{CHEF_RUNDECK_CONTAINER_IP} #{CHEF_SERVER_CONTAINER_IP}")
  else
    puts "Chef-Rundeck already installed/configured and running. Skipping...".bold
  end
end

def fetch_chef_keys
  system("scripts/fetch_chef_keys.sh #{CHEF_SERVER_CONTAINER_NAME} #{CHEF_PORT} #{DOCKER_FOLDER}")
end
