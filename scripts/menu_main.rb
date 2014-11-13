#!/usr/bin/ruby

require 'colorize'
vars=File.expand_path("../../vars", __FILE__)
eval File.read(vars)

require_relative "menu_chef.rb"

class Application
  def initialize
    rundeck_menu
    main_menu
  end

  def rundeck_menu
    puts "\nDo you want to install Rundeck?".bold
    puts "  1: Yes\n  2: No".green
    case gets.strip
      when "1"
        puts "Installing Rundeck...".bold
        vars= {"cloud_server" => CLOUD_SERVER,
               "interface_out" => INTERFACE_OUT,
               "rundeck_version" => RUNDECK_VERSION}
        vars=check_vars(vars)
        system("sudo scripts/install_rundeck.sh #{CLOUD_SERVER} #{INTERFACE_OUT} #{RUNDECK_VERSION}")
      when "2"
        puts "Moving on..."
      else
        rundeck_menu
    end
  end

  def restart_rundeck
    puts "\nRestart Rundeck to apply new groups to the rundeck user...".bold
    rundeck_url=`sudo cat /etc/rundeck/framework.properties |grep framework.server.url |awk '{print $3}'`.chomp
    self.class.const_set(:RUNDECK_URL, rundeck_url)
    system("sudo service rundeckd restart")
    system("sudo scripts/check_url.sh #{RUNDECK_URL} 60")
    puts "\n"
  end

  def main_menu
    puts "\nWhat would you like to install?".bold
    puts "  1: KVM - Nat only\n  2: KVM - Nat + Floating IPs\n  3: Docker\n  4: Exit...".green
    case gets.strip
      when "1"
        files=["generate_scripts.rb", "setup_db.rb", "get_first_cloud_image.rb"]
        files.each do |file|
          require_relative "../kvm/#{file}"
        end
        puts "Installing KVM (NAT only) and generating Rundeck jobs...".bold
        vars= {"kvm_folder" => KVM_FOLDER,
               "backend" => BACKEND,
               "mysql_password" => MYSQL_PASSWORD,
               "database_name" => DATABASE_NAME,
               "db_kvm_table" => DB_KVM_TABLE,
               "ssh_keys" => SSH_KEYS}
        vars=check_vars(vars)
        self.class.const_set(:FLOATING, "no")
        system("sudo scripts/install_kvm.sh #{KVM_FOLDER} #{BACKEND} #{MYSQL_PASSWORD}")
        generate_scripts BACKEND, DATABASE_NAME, DB_KVM_TABLE, MYSQL_PASSWORD, KVM_FOLDER, SSH_KEYS, FLOATING
        setup_kvm_db BACKEND, DATABASE_NAME, DB_KVM_TABLE, MYSQL_PASSWORD
        get_first_cloud_image KVM_FOLDER, FIRST_IMAGE_SOURCE
        chef_menu
        system("sudo chown -R rundeck. #{KVM_FOLDER}")
      when "2"
        files=["generate_scripts-floating.rb", "setup_db.rb", "get_first_cloud_image.rb"]
        files.each do |file|
          require_relative "../kvm/#{file}"
        end
        puts "Installing KVM (NAT + Floating IP) and generating Rundeck jobs...".bold
        vars= {"kvm_folder" => KVM_FOLDER,
               "backend" => BACKEND,
               "mysql_password" => MYSQL_PASSWORD,
               "database_name" => DATABASE_NAME,
               "db_kvm_table" => DB_KVM_TABLE,
               "start_ip" => START_IP,
               "end_ip" => END_IP,
               "gateway_ip" => GATEWAY_IP,
               "ssh_keys" => SSH_KEYS}
        vars=check_vars(vars)
        self.class.const_set(:FLOATING, "yes")
        system("sudo scripts/install_kvm.sh #{KVM_FOLDER} #{BACKEND} #{MYSQL_PASSWORD}")
        generate_scripts BACKEND, DATABASE_NAME, DB_KVM_TABLE, MYSQL_PASSWORD, KVM_FOLDER, START_IP, END_IP, GATEWAY_IP, SSH_KEYS, FLOATING
        setup_kvm_db BACKEND, DATABASE_NAME, DB_KVM_TABLE, MYSQL_PASSWORD
        get_first_cloud_image KVM_FOLDER, FIRST_IMAGE_SOURCE
        chef_menu
        system("sudo chown -R rundeck. #{KVM_FOLDER}")
      when "3"
        puts "Installing Docker and generating Rundeck jobs...".bold
        vars= {"docker_folder" => DOCKER_FOLDER}
        vars=check_vars(vars)
        system("sudo scripts/install_docker.sh #{DOCKER_FOLDER}")
        system("sudo su rundeck -c 'rd-project -p docker-control -a create'")
        system("sudo su rundeck -c 'rd-jobs load -r -f #{DOCKER_FOLDER}/rundeck_jobs.xml -p docker-control'")
      when "4"
        exit 1
      else
        main_menu
    end
    install_done
  end

  def bundle_install(gem)
    require 'erb'
    template = ERB.new(File.read("scripts/templates/Gemfile.erb"))
    xml_content = template.result(binding)
    File.open("Gemfile", "w") do |file|
      file.puts xml_content
    end
    system("su #{ENV['SUDO_USER']} -c 'bundle install'")
  end

  def check_vars(variables)
    vars=[]
    variables.each do |name, var|
      if var.empty?
        puts "#{name.upcase} is empty!".red + " Please a value:"
        var=gets.chomp
        new_value=self.class.const_set(name.upcase, "#{var}")
        vars << new_value
      end
    end
    return vars
  end

  def install_done
    puts "\nDo you want to install something else?".bold
    puts "  1: Yes\n  2: No".green
    case gets.strip
      when "1"
        main_menu
      when "2"
        restart_rundeck
        rundeck_url_full=`sudo cat /etc/rundeck/framework.properties |grep framework.server.url |awk '{print $3}'`.chomp.bold+"/menu/home".bold
puts "
            _
          ,' '.
         /     \\
       ^ |  _  | ^
      | || / \\ || |
      | |||.-.||| |    ###############
      | |||   ||| |    Mission_Control installation completed!
      | |||   ||| |    Go to: #{rundeck_url_full}
      | ||| M ||| |    Rundeck: Username: admin | Password: admin
      | ||| . ||| |    ########
      | ,'  C  '. |
      ,'__     __`.
     /____  |  ____\\
      /_\\ |_|_| /_\\
\n"
      else
        install_done
    end
  end
  Application.new
end
