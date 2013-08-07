Pod::Spec.new do |s|
  s.name = 'CoconutKit'
  s.version = '2.0.3'
  s.license = 'MIT'
  s.summary = 'CoconutKit is a library of high-quality iOS components.'
  s.homepage = 'https://github.com/defagos/CoconutKit'
  s.author = { 'Samuel Défago' => 'defagos@gmail.com' }
  s.source = { :git => 'https://github.com/defagos/CoconutKit.git', :tag => '2.0.3' }
  s.platform = :ios, '4.3'
  
  s.description = 'CoconutKit is a library of high-quality iOS components written at hortis le studio and in my spare time. It includes several tools for dealing with view controllers, multi-threading, view animations, as well as some new controls and various utility classes. These components are meant to make the life of an iOS programmer easier by reducing the boilerplate code written every day, improving code quality and enforcing solid application architecture.'
  
  s.source_files = 'CoconutKit/Sources/**/*.{h,m}'
  s.prefix_header_file = 'CoconutKit/CoconutKit-Prefix.pch'
  
  s.frameworks = 'CoreData', 'CoreGraphics', 'CoreText', 'Foundation', 'MessageUI', 'MobileCoreServices', 'QuartzCore', 'UIKit'
  s.requires_arc = false
  s.resource_bundle = { 'CoconutKit-resources' => ['CoconutKit-resources/Resources/{Images,Nibs}/*', 'CoconutKit-resources/Resources/*.lproj'] }
  
  s.prefix_header_contents = <<-EOS
#ifdef __OBJC__
  #import "CoconutKit.h"
#endif
EOS
  
  s.pre_install do |pod, target_definition|
    Dir.chdir File.join(pod.root, 'CoconutKit') do
      public_headers = File.read('publicHeaders.txt').split("\n")
      File.open('Sources/CoconutKit.h', 'w') do |file|
        file.puts File.read('CoconutKit-Prefix.pch')
        public_headers.each { |h| file.puts "#import <CoconutKit/#{h}>" }
      end
      public_headers << 'CoconutKit.h'
      s.public_header_files = public_headers.map { |f| File.join('**', f) }
    end
  end
end
