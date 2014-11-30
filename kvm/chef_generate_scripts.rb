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

  system("sudo su rundeck -c 'rd-project -p kvm-control_with-Chef -a create --resources.source.2.config.url=http://localhost:9980 --resources.source.2.type=url --resources.source.2.config.timeout=60 --resources.source.2.config.cache=false'")
  system("sudo su rundeck -c 'rd-jobs load -r -f #{kvm_folder}/chef-rundeck_jobs.xml -p kvm-control_with-Chef'")

  system("sudo chown -R rundeck. #{kvm_folder}")

end
