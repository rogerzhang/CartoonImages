# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'CartoonImages' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  platform :ios, '16.0'

  pod 'ReSwift'
  pod 'KeychainSwift'
  pod 'AlertToast'
  pod 'SDWebImage'
  pod 'Moya/Combine', '~> 15.0'

  target 'CartoonImagesTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'CartoonImagesUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "16.0"
    end
  end
end
