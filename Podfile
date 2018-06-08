# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

# source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

target 'Dollar Pizza Finder' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Dollar Pizza Finder

pod 'GooglePlaces'
pod 'Firebase/Core'
pod 'Firebase/Database'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
    end
  end
end

end