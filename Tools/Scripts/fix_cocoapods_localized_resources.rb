#!/usr/bin/ruby

# Fix a CocoaPods issue when signing localized resources
# See https://github.com/CocoaPods/CocoaPods/issues/1653 for more information

require 'FileUtils'

resources_directory = File.expand_path(File.join(File.dirname(__FILE__), '../../CoconutKit-resources'))
generated_resources_directory = File.join(File.dirname(__FILE__), 'GeneratedResources')

# Create a directory for generated resources
if Dir.exists?(generated_resources_directory)
  FileUtils.rm_rf(generated_resources_directory)
end
FileUtils.mkdir_p(generated_resources_directory)

# Copy existing files to the directory for generated resources
Dir["#{resources_directory}/**/*.lproj"].each do |file|
  next unless File.directory?(file)

  FileUtils.cp_r(file, generated_resources_directory)
end

# Convert to binary plist
Dir["#{generated_resources_directory}/**/*.strings"].each do |file|
  `plutil -convert binary1 #{file}`
end
