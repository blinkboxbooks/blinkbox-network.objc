Pod::Spec.new do |s|

  s.name         = "BBBAPI"
  s.version      = "0.0.1"
  s.summary      = "API library for communicating with Blinkbox Books API"

  s.description  = <<-DESC
                   Use it, it's awesome!
                   Use it, it's awesome!
                   Use it, it's awesome!
                   Use it, it's awesome!
                   Use it, it's awesome!
                   Use it, it's awesome!
                   DESC

  s.homepage     = "http://blinkboxbooks.com"
  s.license      = "BBB"
  s.authors      = { "iOS developers" => "ios@blinkbox.com" }

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://git.mobcastdev.com/iOS/BBBAPI.git", :tag => "0.0.1" }
  s.source_files  = "BBBAPI/BBBAPI/Classes/*.{h,m}"
  s.framework  = "Foundation"
  s.requires_arc = true
  s.dependency "CocoaLumberjack"

end
