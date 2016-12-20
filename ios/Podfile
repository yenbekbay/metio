source 'https://github.com/CocoaPods/Specs'

platform :ios, '8.0'

inhibit_all_warnings!
use_frameworks!

target 'Metio' do
  pod 'AFNetworking'
  pod 'Analytics/Segmentio'
  pod 'CocoaLumberjack'
  pod 'Crashlytics'
  pod 'CRToast'
  pod 'DeviceUtil'
  pod 'DGActivityIndicatorView'
  pod 'Fabric'
  pod 'JVFloatLabeledTextField'
  pod 'Parse'
  pod 'pop'
  pod 'ReactiveCocoa', '~> 4.0-alpha'
  
  pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

target :unit_tests, :exclusive => true do
  link_with 'MetioTests'
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMock'
  pod 'OHHTTPStubs'
end

post_install do | installer |
  require 'fileutils'

  pods_acknowledgements_path = "Pods/Target Support Files/Pods/Pods-Acknowledgements.plist"
  settings_bundle_path = Dir.glob("**/*Settings.bundle*").first

  if File.file?(pods_acknowledgements_path)
    puts "Copying acknowledgements to Settings.bundle"
    FileUtils.cp_r(pods_acknowledgements_path, "#{settings_bundle_path}/Acknowledgements.plist", :remove_destination => true)
  end

  app_plist = "Metio/Resources/Other-Sources/Info.plist"
  plist_buddy = "/usr/libexec/PlistBuddy"
  version = `#{plist_buddy} -c "Print CFBundleShortVersionString" "#{app_plist}"`.strip

  puts "Updating CocoaPods frameworks' version numbers to #{version}"
    
  installer.pods_project.targets.each do |target|
    `#{plist_buddy} -c "Set CFBundleShortVersionString #{version}" "Pods/Target Support Files/#{target}/Info.plist"`
  end
end

