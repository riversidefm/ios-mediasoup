Pod::Spec.new do |spec|
	spec.summary = "Swift client for Mediasoup 3"
	spec.description = "Swift wrapper for libmediasoupclient"
	spec.homepage = "https://github.com/VLprojects/mediasoup-client-swift"
	spec.license = "MIT"
	spec.author = {
		"Alexander Gorbunov" => "gorbunov.a@vlprojects.pro"
	}
	
	spec.name = "Mediasoup-Client-Swift-Device"
	spec.version = "0.4.2"
	spec.platform = :ios, "14.0"
	spec.module_name = "Mediasoup"
	spec.module_map = "Mediasoup/Mediasoup.modulemap"

	spec.source = {
		:path => '/Users/andreykrit/Documents/mediasoup-client-swift-device'
		#:tag => spec.version.to_s
	}

	spec.frameworks =
		"AVFoundation",
		"AudioToolbox",
		"CoreAudio",
		"CoreMedia",
		"CoreVideo"

	spec.vendored_frameworks =
		"bin/Mediasoup.xcframework",
		"bin/WebRTC.xcframework"
end
