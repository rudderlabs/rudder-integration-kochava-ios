require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

kochava_sdk_version = '~> 7.1'
rudder_sdk_version = '~> 1.12'

Pod::Spec.new do |s|
  s.name             = 'Rudder-Kochava'
  s.version          = package['version']
  s.summary          = 'Privacy and Security focused Segment-alternative. Kochava Native SDK integration support.'

  s.description      = <<-DESC
Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.
                       DESC

  s.homepage         = 'https://github.com/rudderlabs/rudder-integration-kochava-ios'
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { 'RudderStack' => 'arnab@rudderstack.com' }
  s.source           = { :git => 'https://github.com/rudderlabs/rudder-integration-kochava-ios.git', :tag => "v#{s.version}" }
  
  s.ios.deployment_target = '12.4'

  s.source_files = 'Rudder-Kochava/Classes/**/*'

  s.static_framework = true

  if defined?($KochavaSDKVersion)
      Pod::UI.puts "#{s.name}: Using user specified Kochava SDK version '#{$KochavaSDKVersion}'"
      kochava_sdk_version = $KochavaSDKVersion
  else
      Pod::UI.puts "#{s.name}: Using default Kochava SDK version '#{kochava_sdk_version}'"
  end
  
  if defined?($RudderSDKVersion)
      Pod::UI.puts "#{s.name}: Using user specified Rudder SDK version '#{$RudderSDKVersion}'"
      rudder_sdk_version = $RudderSDKVersion
  else
      Pod::UI.puts "#{s.name}: Using default Rudder SDK version '#{rudder_sdk_version}'"
  end
  
  s.dependency 'Rudder', rudder_sdk_version
  s.dependency 'Apple-Cocoapod-KochavaTracker', kochava_sdk_version

end
