Pod::Spec.new do |s|

  s.name         = "BBBAPI"
  s.version      = "0.0.16"
  s.summary      = "iOS / OSX Objective-C library for communicating with the Blinkbox Books API"

  s.description  = <<-DESC
  
                   This library contains collection of classes that can be 
                   used to communicate with the endpoints of the REST API for
                   Blinkbox Books.
                   Library tries to reflect all webservices to the native domain 
                   for iOS and OSX apps.

                   DESC

  s.homepage     = "http://blinkboxbooks.com"
  s.license      = "MIT"
  s.authors      = { "Tomek Kuźma" => "mapedd@mapedd.com", "Owen Worley" =>"owen@owenworley.co.uk", "Eric Yuan" => "mbaeric@gmail.com" }

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.10"

  s.source       = { :git => "git@github.com:blinkboxbooks/blinkbox-network.objc.git", :tag => s.version.to_s }
  s.source_files  = "BBBAPI/BBBAPI/Classes/*.{h,m}"

  s.framework  = "Foundation"
  s.requires_arc = true

  s.dependency "CocoaLumberjack" , '~> 1.9.2'
  s.dependency "FastEasyMapping", '~>0.5.1'
  s.dependency "NSArray+Functional", '~>1.0.0'

end


