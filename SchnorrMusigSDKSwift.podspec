Pod::Spec.new do |s|

  s.name             = 'SchnorrMusigSDKSwift'
  s.version          = '0.0.1'
  s.summary          = 'A short description of SchnorrMusigSDKSwift.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zksync-sdk/schnorr-musig-sdk-swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "The Matter Labs team" => "hello@matterlabs.dev" }
  s.source           = { :git => 'https://github.com/zksync-sdk/schnorr-musig-sdk-swift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.source_files = 'SchnorrMusigSDKSwift/**/*.{swift,h}'
  
  s.vendored_libraries = "SchnorrMusigSDKSwift/Lib/*.{a}"
  
  s.pod_target_xcconfig = { :VALID_ARCHS => 'arm64 arm64e armv7 armv7s x86_64' }

end
