Pod::Spec.new do |s|
  s.name = 'CoconutKit'
  s.version = '2.1'
  s.license = 'MIT'
  s.summary = 'CoconutKit is a library of high-quality iOS components.'
  s.homepage = 'https://github.com/defagos/CoconutKit'
  s.author = { 'Samuel Défago' => 'defagos@gmail.com' }
  s.source = { :git => 'https://github.com/defagos/CoconutKit.git', :tag => '2.1' }
  s.social_media_url = 'http://twitter.com/defagos'
  s.platform = :ios, '7.0'
  
  s.description = <<-DESC
                  CoconutKit is a library of high-quality iOS components, including:

                  * Custom view controller containers
                  * Declarative UIView and Core Animation-based animations
                  * Language change at runtime
                  * Localization in nib files without outlets
                  * Core Data model management and validation made easy
                  * Custom controls
                  * ... and much more!
                  DESC
  
  s.source_files = 'CoconutKit/Sources/**/*.{h,m}'
  s.prefix_header_file = 'CoconutKit/CoconutKit-Prefix.pch'
  
  s.frameworks = 'CoreData', 'CoreGraphics', 'CoreText', 'Foundation', 'MessageUI', 'MobileCoreServices', 'QuartzCore', 'QuickLook', 'UIKit'
  s.requires_arc = true

  # Process the publicHeaders.txt file listing public headers to generate a public header directory as well as a global header file
  s.preserve_paths = 'CoconutKit/publicHeaders.txt'  
  s.prepare_command = 'ruby Tools/Scripts/generate_public_headers.rb'
  s.public_header_files = 'Tools/Scripts/GeneratedHeaders/*.h'

  # Do not use CoconutKit-resources target, use CocoaPods native bundle creation mechanism
  s.resource_bundle = { 'CoconutKit-resources' => ['CoconutKit-resources/{Images,Nibs}/*', 'CoconutKit-resources/*.lproj/*'] }
end
