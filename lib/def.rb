#!/usr/bin/env ruby

def generate_value (value_name, search, separator, array_name)
array_name=[]
Dir.glob("#{GUESTS_DIR}/*/*.xml").each do |files|
  File.open(files, "r").each_line do |line|
    if line.include?(value_name)
      line.split(' ').each do |split|
        split.split('=').each do |split2|
          if split2.include?("#{search}")
            array_name << split2.tr("#{separator}", '')
          end
        end
      end
    end
  end
end

return array_name
end
