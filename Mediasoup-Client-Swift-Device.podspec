Pod::Spec.new do |spec|
	spec.summary = "Swift client for Mediasoup 3"
	spec.description = "Swift wrapper for libmediasoupclient"
	spec.homepage = "https://github.com/VLprojects/mediasoup-client-swift"
	spec.license = "MIT"
	spec.author = {
		"Andrii Krit" => "andrey.krit@gmail.com"
	}
	
	spec.name = "Mediasoup-Client-Swift-Device"
	spec.version = "0.4.2"
	spec.platform = :macos, "13.0"
	spec.module_name = "Mediasoup"
	spec.module_map = "Mediasoup/Mediasoup.modulemap"

	spec.source = {
        :git => "git@github.com:riversidefm/ios-mediasoup.git",
        :branch => "macos_arm64"
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
