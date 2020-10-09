
Pod::Spec.new do |s|
  s.version                 = "2.0.0"
  s.name                    = "Airship-iOS-Gimbal-Adapter"
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
  s.dependency                "Gimbal", "~> 2.0"
  s.dependency                "Airship/Core", "~> 14.1.2"
end

