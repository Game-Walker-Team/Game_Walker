# Uncomment the next line to define a global platform for your project
 platform :ios, '14.0'

target 'Game_Walker' do
  use_frameworks!

  # Pods for Game_Walker

  pod 'FirebaseAnalytics'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseFirestoreSwift'
  pod "GMStepper"
  pod "PromiseKit", "~> 6.8"
  pod 'IQKeyboardManagerSwift'

end
post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
