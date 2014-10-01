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
                  DESC
  
  s.source_files = 'CoconutKit/Sources/**/*.{h,m}'
  s.prefix_header_file = 'CoconutKit/CoconutKit-Prefix.pch'
  
  s.frameworks = 'CoreData', 'CoreGraphics', 'CoreText', 'Foundation', 'MessageUI', 'MobileCoreServices', 'QuartzCore', 'UIKit'
  s.requires_arc = true
  s.preserve_paths = 'CoconutKit/publicHeaders.txt'
  s.resource_bundle = { 'CoconutKit-resources' => ['CoconutKit-resources/Resources/{Images,Nibs}/*', 'CoconutKit-resources/Resources/*.lproj/*'] }
end
