#!/usr/bin/ruby

# Fix a CocoaPods issue when signing localized resources
# See https://github.com/CocoaPods/CocoaPods/issues/1653 for more information

require 'FileUtils'

resources_directory = File.expand_path(File.join(File.dirname(__FILE__), '../../CoconutKit-resources'))
fixed_reources_directory = File.join(File.dirname(__FILE__), 'FixedResources')

# Create a directory for generated resources
if Dir.exists?(fixed_reources_directory)
  FileUtils.rm_rf(fixed_reources_directory)
end
FileUtils.mkdir_p(fixed_reources_directory)

# Copy existing files to the directory for generated resources
Dir["#{resources_directory}/**/*.lproj"].each do |file|
  next unless File.directory?(file)

  FileUtils.cp_r(file, fixed_reources_directory)
end

# Convert to binary plist
Dir["#{fixed_reources_directory}/**/*.strings"].each do |file|
  `plutil -convert binary1 #{file}`
end
