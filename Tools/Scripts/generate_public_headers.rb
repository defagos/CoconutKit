#!/usr/bin/ruby

# Create the public header list for use with CocoaPods

require 'FileUtils'

project_directory = File.expand_path(File.join(File.dirname(__FILE__), '../../CoconutKit'))
generated_headers_directory = File.join(File.dirname(__FILE__), 'GeneratedHeaders')

# Create a directory for generated headers
if Dir.exists?(generated_headers_directory)
  FileUtils.rm_rf(generated_headers_directory)
end
FileUtils.mkdir_p(generated_headers_directory)

# Generate the global public header
public_headers = File.read(File.join(project_directory, 'publicHeaders.txt')).split("\n")  
File.open(File.join(generated_headers_directory, 'CoconutKit.h'), 'w') do |file|
  file.puts(File.read(File.join(project_directory, 'CoconutKit-Prefix.pch')))
  public_headers.each do |header| 
    file.puts "#import <CoconutKit/#{header}>"
  end
end

# Symlink all public headers
sources_directory = File.join(project_directory, 'Sources')
public_headers.each do |file_name|
  Dir["#{sources_directory}/**/#{file_name}"].each do |file|
    FileUtils.ln_s(file, File.join(generated_headers_directory, file_name))
  end
end
