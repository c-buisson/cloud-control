#!/usr/bin/ruby

def get_first_cloud_image(kvm_folder, first_image_source)
  filename = first_image_source.split(/\?/).first.split(/\//).last
  if File.exist?(kvm_folder+"/sources/cloud_images/"+filename)
    puts "#{filename} is already in #{kvm_folder}/sources/cloud_images/ skipping..."
  elsif File.exist?(kvm_folder+"/sources/iso/"+filename)
    puts "#{filename} is already in #{kvm_folder}/sources/iso/ skipping..."
  else
    system("sudo ruby #{kvm_folder}/get_images.rb #{first_image_source}")
  end
end
