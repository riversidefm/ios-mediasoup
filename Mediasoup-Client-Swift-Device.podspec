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
	spec.osx.deployment_target = '13.0'
	spec.module_name = "Mediasoup"
	spec.module_map = "Mediasoup/Mediasoup.modulemap"

	spec.source = {
        :git => "git@github.com:riversidefm/ios-mediasoup.git"
	}

	spec.frameworks =
		"AVFoundation",
		"AudioToolbox",
		"CoreAudio",
		"CoreMedia",
		"CoreVideo"




	# Add a build step that executes build_macos.sh only in development
	if ENV['DEVELOPMENT'] == 'true'
		spec.script_phases = [
			{
				:name => "Build Mediasoup",
				:script => "cd $PROJECT_DIR/../../ios-mediasoup && PATH=/opt/homebrew/bin/:$PATH ./build_macos_dev.sh",
				:execution_position => :before_compile,
				:always_out_of_date => "1",
				:output_files => ["build/Mediasoup.xcframework", "bin/mediasoupclient.xcframework", "bin/sdptransform.xcframework"]
			}
		]

		spec.vendored_frameworks =
			"Mediasoup/dependencies/webrtc/src/build/mac/arm64/WebRTC.framework",
			"build/Mediasoup.xcframework"

		# spec.vendored_libraries =
		# 	"build/libmediasoupclient/mac/arm64/libmediasoupclient/Debug/libmediasoupclient.a",
		# 	"build/libmediasoupclient/mac/arm64/libsdptransform/Debug/libsdptransform.a"
		
	else
		spec.vendored_frameworks =
			"bin/Mediasoup.xcframework",
			"bin/WebRTC.xcframework"
	end

end
