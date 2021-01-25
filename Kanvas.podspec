Pod::Spec.new do |spec|
  spec.name         = "Kanvas"
  spec.version      = "1.0.0-rc"
  spec.summary      = "A media editor and camera for iOS."
  spec.homepage     = "https://github.com/tumblr/kanvas-ios"
  spec.license      = "MPLv2"
  spec.source       = { :git => "https://github.com/tumblr/kanvas-ios.git",
  		        :tag => "v#{spec.version}" }
  spec.authors      = { "Jimmy Schementi" => "jimmys@tumblr.com",
                        "Tony Cheng" => "tony@getkanvas.com" }
  spec.platform     = :ios, "13.0"
  spec.swift_version = "4.2"
  spec.requires_arc = true
  spec.frameworks = "Foundation", "GLKit", "OpenGLES", "UIKit"
  spec.source_files  = "Classes/**/*.{h,m,swift,vsh,glsl}"
  spec.resource_bundles = { "Kanvas" => "Resources/*" }
  spec.pod_target_xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => "GLES_SILENCE_DEPRECATION=1" }
end
