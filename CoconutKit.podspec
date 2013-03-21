Pod::Spec.new do |s|
  s.name = 'CoconutKit'
  s.version = '2.0.2'
  s.license = 'MIT'
  s.summary = 'CoconutKit is a library of high-quality iOS components.'
  s.homepage = 'https://github.com/defagos/CoconutKit'
  s.author = { 'Samuel Défago' => 'defagos@gmail.com' }
  s.source = { :git => 'https://github.com/defagos/CoconutKit.git', :tag => '2.0.2' }
  s.platform = :ios, '4.0'
  
  s.description = 'CoconutKit is a library of high-quality iOS components written at hortis le studio and in my spare time. It includes several tools for dealing with view controllers, multi-threading, view animations, as well as some new controls and various utility classes. These components are meant to make the life of an iOS programmer easier by reducing the boilerplate code written every day, improving code quality and enforcing solid application architecture.'
  
  s.source_files = 'CoconutKit/Sources/**/*.{h,m}'
  s.prefix_header_file = 'CoconutKit/CoconutKit-Prefix.pch'
  
  s.frameworks = 'CoreData', 'MessageUI', 'QuartzCore'
  s.requires_arc = false
  
  s.pre_install do |pod, _|
    public_headers = (pod.root + 'CoconutKit/publicHeaders.txt').read.split("\n")
    s.public_header_files = public_headers.map { |f| File.join('CoconutKit/**', f) }
  end
  
  def s.post_install(target_installer)
    puts "\nGenerating CoconutKit resources bundle\n".yellow if config.verbose?
    Dir.chdir File.join(config.project_pods_root, 'CoconutKit') do
      command = "xcodebuild -project CoconutKit-resources/CoconutKit-resources.xcodeproj -target CoconutKit-resources CONFIGURATION_BUILD_DIR=../../Resources"
      command << " 2>&1 > /dev/null" unless config.verbose?
      unless system(command)
        raise ::Pod::Informative, "Failed to generate CoconutKit resources bundle"
      end
    end
    File.open(File.join(config.project_pods_root, target_installer.target_definition.copy_resources_script_name), 'a') do |file|
      file.puts "install_resource 'Resources/CoconutKit.bundle'"
    end
  end
  
end
