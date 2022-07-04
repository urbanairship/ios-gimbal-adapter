
Pod::Spec.new do |s|
  s.version                 = "4.1.1"
  s.name                    = "AirshipGimbalAdapter"
  s.summary                 = "An adapter for integrating Gimbal place events with Airship."
  s.documentation_url       = "https://github.com/urbanairship/ios-gimbal-adapter"
  s.homepage                = "https://www.airship.com"
  s.author                  = { "Airship" => "support@airship.com" }
  s.license                 = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.source                  = { :git => "https://github.com/urbanairship/ios-gimbal-adapter.git", :tag => s.version.to_s }
  s.ios.deployment_target   = "11.0"
  s.swift_version           = "5.0"
  s.source_files            = "Pod/Classes/*"
  s.requires_arc            = true
  s.dependency                "Gimbal", "2.85"
  s.dependency                "Airship", "16.7"
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end