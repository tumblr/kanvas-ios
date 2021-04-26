Pod::Spec.new do |spec|
  spec.name         = "KanvasCamera"
  spec.version      = "1.0.3"
  spec.summary      = "A custom camera built for iOS."
  spec.homepage     = "https://github.com/tumblr/kanvas-ios"
  spec.license      = "MPLv2"
  spec.source       = { :git => "https://github.com/tumblr/kanvas-ios.git",
  		        :tag => "#{spec.version}" }
  spec.authors      = { "Jimmy Schementi" => "jimmys@tumblr.com",
                        "Tony Cheng" => "tony@getkanvas.com" }
  spec.platform     = :ios, "13.0"
  spec.swift_version = "4.2"
  spec.requires_arc = true
  spec.frameworks = "Foundation", "GLKit", "OpenGLES", "UIKit"
  spec.source_files  = "Classes/**/*.{h,m,swift,vsh,glsl}"
  spec.resource_bundles = { "KanvasCamera" => "Resources/*" }
  spec.user_target_xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => "GLES_SILENCE_DEPRECATION=1" }
  spec.pod_target_xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => "GLES_SILENCE_DEPRECATION=1" }
end
