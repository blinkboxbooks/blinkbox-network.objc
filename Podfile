source 'git@git.mobcastdev.com:iOS/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'

workspace 'BBBAPI'
xcodeproj 'BBBAPI/BBBAPI.xcodeproj'

target :BBBAPI do
	pod 'CocoaLumberjack', '~>1.9.2'
	pod 'FastEasyMapping', '~>0.5.1'
    pod 'NSArray+Functional', '~>1.0.0'
end

target :BBBAPITests, :exclusive => true do
	pod 'OHHTTPStubs', '3.1.7'
	pod 'OCMock', '~> 3.1.1'
end

