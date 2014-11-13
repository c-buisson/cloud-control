#!/usr/bin/ruby
require 'erb'

def chef_menu
  puts "\nDo you want to setup a Docker container with Chef server?".bold
  puts "  1. Yes\n  2. No".green
  case gets.strip
    when "1"
      vars= {"chef_server_container_name" => CHEF_SERVER_CONTAINER_NAME,
             "docker_folder" => DOCKER_FOLDER
            }
      vars=check_vars(vars)
      puts "Installing Docker...".bold
      system("sudo scripts/install_docker.sh #{DOCKER_FOLDER}")
      puts "\nDownloading container and start #{CHEF_SERVER_CONTAINER_NAME}".bold
      system("scripts/install_docker_chef-server.sh #{CHEF_SERVER_CONTAINER_NAME} #{DOCKER_FOLDER}")
      generate_rundeck_job
    when "2"
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
  system("sudo su rundeck -c 'rd-project -p chef_server-control -a create'")
  system("sudo su rundeck -c 'rd-jobs load -r -f #{DOCKER_FOLDER}/rundeck_jobs-chef.xml -p chef_server-control'")
end
