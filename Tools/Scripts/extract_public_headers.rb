#!/usr/bin/ruby

# Create the public header list for use with CocoaPods

require 'FileUtils'

project_directory = File.expand_path(File.join(File.dirname(__FILE__), '../../CoconutKit'))
public_headers_directory = File.join(File.dirname(__FILE__), 'PublicHeaders')

# Create a directory for generated headers
if Dir.exists?(public_headers_directory)
  FileUtils.rm_rf(public_headers_directory)
end
FileUtils.mkdir_p(public_headers_directory)

# Generate the global public header
public_headers = File.read(File.join(project_directory, 'publicHeaders.txt')).split("\n")  
File.open(File.join(public_headers_directory, 'CoconutKit.h'), 'w') do |file|
  public_headers.each do |header| 
    file.puts "#import <CoconutKit/#{header}>"
  end
end

# Move all public headers to a separate directory
sources_directory = File.join(project_directory, 'Sources')
public_headers.each do |file_name|
  Dir["#{sources_directory}/**/#{file_name}"].each do |file|
    FileUtils.mv(file, public_headers_directory)
  end
end
