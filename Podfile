workspace 'BBBAPI'

xcodeproj 'BBBAPI/BBBAPI.xcodeproj'
target :ios, :exclusive => true do
    platform :ios, '7.0'
	link_with 'libBBBAPI.a'
	pod 'CocoaLumberjack'
end

target :osx, :exclusive => true do
	platform :osx, '10.8'
	link_with ['BBBAPI.framework', 'BBBAPI']
	pod 'CocoaLumberjack'
end



