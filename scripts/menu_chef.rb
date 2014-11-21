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
      get_ip_host
      puts "\nDownloading container and start #{CHEF_SERVER_CONTAINER_NAME}".bold
      system("scripts/install_docker_chef-server.sh #{CHEF_SERVER_CONTAINER_NAME} #{DOCKER_FOLDER} #{Application::IP_HOST}")
      generate_rundeck_job
      chef_rundeck
      self.class.const_set(:INSTALL_CHEF, "yes")
    when "2"
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
  system("sudo su rundeck -c 'rd-project -p chef_server-control -a create'")
  system("sudo su rundeck -c 'rd-jobs load -r -f #{DOCKER_FOLDER}/rundeck_jobs-chef.xml -p chef_server-control'")
end

def chef_rundeck
  bundle_install "chef-rundeck"
  unless `ps aux |grep -v grep |grep chef-rundeck`.nil?
    template = ERB.new(File.read("scripts/templates/chef-rundeck.conf.erb"))
    xml_content = template.result(binding)
    File.open("/etc/init/chef-rundeck.conf", "w") do |file|
      file.puts xml_content
    end
    system("sudo initctl reload-configuration")
    puts "\nStarting chef-rundeck...".bold
    system("service chef-rundeck restart")
  end
end
