Pod::Spec.new do |s|

  s.name             = 'SchnorrMusigSDKSwift'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SchnorrMusigSDKSwift.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/belyakove/SchnorrMusigSDKSwift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'belyakove' => 'eugen.belyakov@gmail.com' }
  s.source           = { :git => 'https://github.com/belyakove/SchnorrMusigSDKSwift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.source_files = 'SchnorrMusigSDKSwift/**/*.{swift,h}'
  
  s.vendored_libraries = "SchnorrMusigSDKSwift/Lib/*.{a}"
  
  s.pod_target_xcconfig = { :VALID_ARCHS => 'arm64 arm64e armv7 armv7s x86_64' }

end
