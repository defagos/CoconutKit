Pod::Spec.new do |s|
  s.name = 'CoconutKit'
  s.version = '3.0.rc6'
  s.license = 'MIT'
  s.summary = 'CoconutKit is a library of high-quality iOS components.'
  s.homepage = 'https://github.com/defagos/CoconutKit'
  s.author = { 'Samuel Défago' => 'defagos@gmail.com' }
  s.source = { :git => 'https://github.com/defagos/CoconutKit.git', :tag => s.version.to_s }
  s.social_media_url = 'http://twitter.com/defagos'
  s.platform = :ios, '7.0'
  
  s.description = <<-DESC
                  CoconutKit is a productivity framework for iOS, crafted with love and focusing on ease of use. It provides a convenient, Cocoa-friendly toolbox to help you efficiently write robust and polished native applications.
                  DESC
                  
  s.frameworks = 'CoreData', 'CoreGraphics', 'CoreText', 'Foundation', 'MessageUI', 'MobileCoreServices', 'QuartzCore', 'QuickLook', 'UIKit', 'WebKit'

  # The spec uses ARC for compilation. Files which cannot be compiled using ARC are moved to a subspec
  MAZeroingWeakRef_source_files = 'CoconutKit/Sources/Externals/MAZeroingWeakRef-75695a81/*.m'
  MAZeroingWeakRef_header_files = 'CoconutKit/Sources/Externals/MAZeroingWeakRef-75695a81/*.h'

  # ARC source files. Generated headers must be added as well since public .framework headers are setup in the generated Pods
  # target, and therefore must belong to the source_files to be taken into account. This trick is not needed for usual
  # static lib Pods integration, but does not hurt since header files are everywhere the same
  s.requires_arc = true
  s.source_files = 'CoconutKit/Sources/**/*.{h,m}', 'Tools/Scripts/GeneratedHeaders/*.h'
  s.exclude_files = MAZeroingWeakRef_source_files

  # Non-ARC source files
  s.subspec 'fno-objc-arc' do |subspec|
    subspec.requires_arc = false
    subspec.source_files = MAZeroingWeakRef_source_files
    subspec.public_header_files = nil
  end

  # Process the publicHeaders.txt file listing public headers to generate a public header directory as well as a global header file
  # TODO: An additional CocoaPods temporary fix has been added, see https://github.com/CocoaPods/CocoaPods/issues/1653.
  s.preserve_paths = 'Tools/Scripts/GeneratedHeaders', 'Tools/Scripts/GeneratedResources'

  # Warning: This command is not executed if the pod is installed via :path, see http://guides.cocoapods.org/syntax/podspec.html
  s.prepare_command = <<-CMD
                      ruby Tools/Scripts/fix_cocoapods_localized_resources.rb
                      ruby Tools/Scripts/generate_public_headers.rb
                      CMD
  s.public_header_files = 'Tools/Scripts/GeneratedHeaders/*.h'

  # Do not use CoconutKit-resources target, use CocoaPods native bundle creation mechanism
  # TODO: Replace localized resources with 'CoconutKit-resources/*.lproj' when the bug above has been fixed
  s.resource_bundle = { 'CoconutKit-resources' => ['CoconutKit-resources/{HTML,Images,Nibs}/*', 'Tools/Scripts/GeneratedResources/*.lproj'] }
end
