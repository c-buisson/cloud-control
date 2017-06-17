#!/usr/bin/ruby
require 'erb'

def chef_menu
  puts "\nDo you want to setup a Docker container with Chef server?".bold
  puts "  1. Yes".green + " - chef-server-control".bold
  puts "  2. No".green
  case gets.strip
    when "1", "y"
      vars= {"chef_server_container_name" => CHEF_SERVER_CONTAINER_NAME,
             "chef_server_container_ip" => CHEF_SERVER_CONTAINER_IP,
             "chef_rundeck_container_name" => CHEF_RUNDECK_CONTAINER_NAME,
             "chef_rundeck_container_ip" => CHEF_RUNDECK_CONTAINER_IP,
             "docker_folder" => DOCKER_FOLDER
            }
      vars=check_vars(vars)
      system("sudo scripts/install_docker.sh #{DOCKER_FOLDER}")
      get_ip_host
      system("scripts/install_docker_chef-server.sh #{CHEF_SERVER_CONTAINER_NAME} #{CHEF_PORT} #{DOCKER_FOLDER} #{CHEF_SERVER_CONTAINER_IP}")
      generate_rundeck_job
      chef_rundeck
      self.class.const_set(:INSTALL_CHEF, "yes")
    when "2", "n"
      self.class.const_set(:INSTALL_CHEF, "no")
      puts "Ok, moving on..."
    else
      chef_menu
  end
end

def generate_rundeck_job
    template = ERB.new(File.read("docker/template/rundeck_jobs-chef.xml.erb"))
    xml_content = template.result(binding)
    File.open("#{DOCKER_FOLDER}/rundeck_jobs-chef.xml", "w") do |file|
      file.puts xml_content
    end
  dir=File.expand_path(File.dirname(__FILE__))
  system("#{dir}/../scripts/create_rd_projects.sh \"chef_server-control\" #{DOCKER_FOLDER}")
end

def chef_rundeck
  unless `sudo docker ps |grep chef-rundeck` != ""
    puts "Setting up chef-rundeck container".bold
    dir=File.expand_path(File.dirname(__FILE__))
    system("scripts/install_docker_chef-rundeck.sh #{CHEF_RUNDECK_CONTAINER_NAME} #{CHEF_RUNDECK_CONTAINER_IP} #{CHEF_SERVER_CONTAINER_IP}")
  else
    puts "Chef-Rundeck already installed/configured and running. Skipping...".bold
  end
end
