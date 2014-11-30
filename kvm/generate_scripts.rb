#!/usr/bin/ruby
require 'erb'

def generate_scripts(backend, database_name, db_kvm_table, mysql_password, kvm_folder, ssh_keys, floating, rundeck_key, bind9, ip_host)
  dir=File.expand_path(File.dirname(__FILE__))

  #Generate ENV file
  template = ERB.new(File.read("#{dir}/templates/ENV.erb"))
  xml_content = template.result(binding)
  File.open("#{kvm_folder}/ENV", "w") do |file|
    file.puts xml_content
  end

  #Generate lib files
  lib_files = ["mysql_backend", "postgres_backend", "generate_static_ip", "lists"]
  lib_files.each do |file|
    template = ERB.new(File.read("#{dir}/templates/#{file}.erb"))
    xml_content = template.result(binding)
    File.open("#{kvm_folder}/lib/#{file}.rb", "w") do |file|
      file.puts xml_content
    end
  end

  #Generate misc files
  misc_files = ["rundeck_jobs.xml", "get_images.rb"]
  misc_files.each do |misc|
    template = ERB.new(File.read("#{dir}/templates/#{misc}.erb"))
    xml_content = template.result(binding)
    File.open("#{kvm_folder}/#{misc}", "w") do |file|
      file.puts xml_content
    end
  end

  system("sudo su rundeck -c 'rd-project -p kvm-control -a create'")
  system("sudo su rundeck -c 'rd-jobs load -r -f #{kvm_folder}/rundeck_jobs.xml -p kvm-control'")

  #Generate user-data template file
  var = "<%= ip %>"
  hostname = "<%= name %>"
  template = ERB.new(File.read("#{dir}/templates/TEMPLATE-user-data-nat.erb"))
  xml_content = template.result(binding)
  File.open("#{kvm_folder}/templates/TEMPLATE-user-data-nat.erb", "w") do |file|
    file.puts xml_content
  end

  system("sudo cp #{dir}/templates/TEMPLATE.xml.erb #{kvm_folder}/templates/")
  system("sudo chown -R rundeck. #{kvm_folder}")

  puts "\nAll the scripts were generated!\n Mission_Control folder location: #{kvm_folder}\n Backend: #{backend}"
end
