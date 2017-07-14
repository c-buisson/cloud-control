#!/usr/bin/ruby
require 'erb'

def chef_generate_scripts(backend, kvm_folder, floating, bind9)
  dir=File.expand_path(File.dirname(__FILE__))

  #Generate Rundeck xml
  template = ERB.new(File.read("#{dir}/templates/chef-rundeck_jobs.xml.erb"))
  xml_content = template.result(binding)
  File.open("#{kvm_folder}/chef-rundeck_jobs.xml", "w") do |file|
    file.puts xml_content
  end

  system("#{dir}/../scripts/rd_cmd.sh \"kvm-control_with-Chef\" #{kvm_folder}")
  system("chown -R rundeck. #{kvm_folder}")

end
