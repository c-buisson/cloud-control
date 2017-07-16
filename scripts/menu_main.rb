#!/usr/bin/ruby

require 'colorize'
require 'ipaddr'
vars=File.expand_path("../../vars", __FILE__)
eval File.read(vars)

require_relative "menu_chef.rb"

class Installer
  def initialize
    get_ip_host
    rundeck_menu
    main_menu
  end

  def rundeck_menu
    puts "\nDo you want to install or update Rundeck?".bold
    puts "  1: Yes\n  2: No (Rundeck already installed)".green
    puts "  3: Exit..."
    case gets.strip
      when "1", "y"
        puts "Installing Rundeck...".bold
        system("scripts/install_rundeck.sh #{IP_HOST} #{RUNDECK_VERSION} #{BACKEND} #{MYSQL_PASSWORD}") or exit
      when "2", "n"
        puts "Moving on..."
      when "3"
        stop_install
      else
        rundeck_menu
    end
  end

  def main_menu
    puts "\nWhat would you like to install?".bold
    puts "  1: kvm-control".green + " - Nat only".bold
    puts "  2: kvm-control".green + " - Nat + Floating IPs".bold
    puts "  3: docker-control".green
    puts "  4: Exit..."
    case gets.strip
      when "1"
        files=["generate_scripts.rb", "chef_generate_scripts.rb", "setup_db.rb"]
        files.each do |file|
          require_relative "../kvm/#{file}"
        end
        puts "Installing KVM (NAT only) and generating Rundeck jobs...".bold
        self.class.const_set(:FLOATING, "no")
        system("scripts/install_kvm.sh #{KVM_FOLDER} #{BIND9} #{IP_HOST}")
        get_rundeck_key
        generate_scripts BACKEND, DATABASE_NAME, DB_KVM_TABLE, MYSQL_PASSWORD, KVM_FOLDER, SSH_KEYS, FLOATING, RUNDECK_KEY, BIND9, IP_HOST
        setup_kvm_db BACKEND, DATABASE_NAME, DB_KVM_TABLE, MYSQL_PASSWORD
        install_bind9 BIND9, FLOATING
        chef_menu IP_HOST
        if INSTALL_CHEF == "yes"
          chef_generate_scripts BACKEND, KVM_FOLDER, FLOATING, BIND9
        else
          system("scripts/rd_cmd.sh \"remove_chef_jobs\" #{KVM_FOLDER}")
        end
        system("scripts/rd_cmd.sh \"get_first_source\" #{FIRST_IMAGE_SOURCE}")
        system("chown -R rundeck. #{KVM_FOLDER}")
      when "2"
        # Check if there is a bridge inteface named 'br0'
	if BR0_PRESENT == false
	  puts "Please create a bridge interface named 'br0' in order to use floating IPs!".red
	  exit 1
	end
        files=["generate_scripts-floating.rb", "chef_generate_scripts.rb", "setup_db.rb"]
        files.each do |file|
          require_relative "../kvm/#{file}"
        end
        puts "Installing KVM (NAT + Floating IP) and generating Rundeck jobs...".bold
        vars={"start_ip" => START_IP,
               "end_ip" => END_IP,
               "gateway_ip" => GATEWAY_IP}
        vars=check_vars(vars)
        check_vars_ips_for_floating
        self.class.const_set(:FLOATING, "yes")
        system("scripts/install_kvm.sh #{KVM_FOLDER} #{BIND9} #{IP_HOST}")
        get_rundeck_key
        generate_scripts BACKEND, DATABASE_NAME, DB_KVM_TABLE, MYSQL_PASSWORD, KVM_FOLDER, START_IP, END_IP, GATEWAY_IP, SSH_KEYS, FLOATING, RUNDECK_KEY, BIND9, IP_HOST
        setup_kvm_db BACKEND, DATABASE_NAME, DB_KVM_TABLE, MYSQL_PASSWORD
        install_bind9 BIND9, FLOATING
        chef_menu IP_HOST
        if INSTALL_CHEF == "yes"
          chef_generate_scripts BACKEND, KVM_FOLDER, FLOATING, BIND9
        else
          system("scripts/rd_cmd.sh \"remove_chef_jobs\" #{KVM_FOLDER}")
        end
        system("scripts/rd_cmd.sh \"get_first_source\" #{FIRST_IMAGE_SOURCE}")
        system("chown -R rundeck. #{KVM_FOLDER}")
      when "3"
        puts "Installing Docker and generating Rundeck jobs...".bold
        system("scripts/install_docker.sh #{DOCKER_FOLDER} #{IP_HOST}")
        system("scripts/rd_cmd.sh \"docker-control\" #{DOCKER_FOLDER}")
      when "4"
        bye
        exit 0
      else
        main_menu
    end
    install_done
  end

  def get_ip_host
    # Get host IP
    if CLOUD_SERVER == "yes"
      ip_host=`curl http://icanhazip.com`.chomp
    end
    require 'socket'
    interfaces={}
    addr_infos = Socket.getifaddrs
    addr_infos.each do |addr_info|
      if addr_info.addr
	interfaces[addr_info.name]=addr_info.addr.ip_address if addr_info.addr.ipv4?
      end
    end
    # Check if the interface has an IP
    interface_present=interfaces.key?(INTERFACE_OUT)
    if interface_present == false
      puts "The INTERFACE_OUT (#{INTERFACE_OUT}) does not have any IP assigned to it!".red
      puts "Check 'ifconfig' and update 'vars' file accordingly."
      exit 1
    else
      self.class.const_set(:IP_HOST, interfaces[INTERFACE_OUT])
      # Check if there is a bridge inteface named 'br0'
      self.class.const_set(:BR0_PRESENT, interfaces.key?('br0'))
    end
  end

  def check_vars_ips_for_floating
    ips = [START_IP, END_IP, GATEWAY_IP]
    # Check if each IPs are valid
    ips.each do |ip|
      begin
	IPAddr.new(ip)
      rescue
	puts "IP (#{ip}) is not valid or nil!\nStopping now...".red
	exit 1
      end
    end
    ip_start = IPAddr.new START_IP
    ip_end = IPAddr.new END_IP
    if ip_start >= ip_end
      puts "START_IP (#{ip_start}) should start before END_IP (#{ip_end})! Please fix!"
      exit 1
    end
  end

  def check_vars(variables)
    # Check if the variables aren't empty in 'vars' file.
    # If a value is missing, ask the user to enter it now.
    vars=[]
    variables.each do |name, var|
      if var.empty?
        puts "#{name.upcase} is empty!".red + " Please add a value:"
        var=gets.chomp
        new_value=self.class.const_set(name.upcase, "#{var}")
        vars << new_value
      end
    end
    return vars
  end

  def get_rundeck_key
    rundeck_key=`cat /var/lib/rundeck/.ssh/id_rsa.pub`.chomp
    self.class.const_set(:RUNDECK_KEY, rundeck_key)
  end

  def install_bind9(install, floating)
    if install == "yes"
      require 'erb'
      system("apt-get -y install bind9")
      system("cp kvm/templates/db.local.erb #{KVM_FOLDER}/templates/db.local.erb")
      system("cp kvm/templates/db.1XX.erb #{KVM_FOLDER}/templates/db.1XX.erb")
      if floating == "yes"
        # Add zone for local network IPs.
        ip_host=IP_HOST.to_s
        puts ip_host.split
        third_byte=ip_host.split(".")[2]
        template = ERB.new(File.read("kvm/templates/named.conf.local.erb"))
        xml_content = template.result(binding)
        File.open("/etc/bind/named.conf.local", "w") do |file|
          file.puts xml_content
        end
      else
        # Add zone for private network (NAT) only.
        third_byte=""
        template = ERB.new(File.read("kvm/templates/named.conf.local.erb"))
        xml_content = template.result(binding)
        File.open("/etc/bind/named.conf.local", "w") do |file|
          file.puts xml_content
        end
      end
      system("adduser rundeck bind")
      system("chmod 775 /etc/bind/")
      system("chown rundeck:bind /etc/bind/db.local")
      system("touch /etc/bind/db.1XX && chown rundeck:bind /etc/bind/db.1XX")
      system("systemctl restart bind9")
    end
  end

  def install_done
    puts "\nDo you want to install something else?".bold
    puts "  1: Yes\n  2: No".green
    case gets.strip
      when "1", "y"
        main_menu
      when "2", "n"
        bye
        exit 0
      else
        install_done
    end
  end

  def stop_install
    puts "\nStopping Mission_Control install!"
    exit 0
  end

  def bye
        rundeck_url_full=`cat /etc/rundeck/framework.properties |grep framework.server.url |awk '{print $3}'`.chomp.bold
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
  end

  Installer.new
end
