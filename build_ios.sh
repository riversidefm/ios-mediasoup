#!/bin/bash

# Stop script on errors.
set -e

NO_INTERACTIVE=false
ONLY_FETCH_DEPS=false

# Parse command line arguments
for arg in "$@"
do
    case $arg in
        --no-interactive)
        NO_INTERACTIVE=true
        shift
        ;;
        --only-fetch-deps)
        ONLY_FETCH_DEPS=true
        shift
        ;;
    esac
done

# Check build time dependencies.
if ! command -v python &> /dev/null
then
	echo 'python could not be found'
	echo 'try next steps:'
	echo '  * run "brew install pyenv"'
	echo '  * run "pyenv install --list" and choose a recent 3.x version say 3.11.2'
	echo '  * run "pyenv install 3.11.2"'
	echo '  * run "pyenv global 3.11.2"'
	echo $'  * run "echo \'eval "$(pyenv init --path)"\' >> ~/.zshrc"'
	exit
fi
if ! command -v cmake &> /dev/null
then
	echo 'cmake could not be found'
	echo 'try next steps:'
	echo '  * run "brew install cmake"'
	exit
fi

# Define working directories.
export PROJECT_DIR=$(pwd)
echo "PROJECT_DIR = $PROJECT_DIR"
export WORK_DIR=$PROJECT_DIR/Mediasoup/dependencies
echo "WORK_DIR = $WORK_DIR"
export BUILD_DIR=$(pwd)/build
echo "BUILD_DIR = $BUILD_DIR"

if [ "$NO_INTERACTIVE" = false ]; then
    export OUTPUT_DIR=$(pwd)/bin
else
    export OUTPUT_DIR=$(pwd)/bin/ios
fi

echo "OUTPUT_DIR = $OUTPUT_DIR"
export PATCHES_DIR=$(pwd)/patches
echo "PATCHES_DIR = $PATCHES_DIR"
export WEBRTC_DIR=$PROJECT_DIR/Mediasoup/dependencies/webrtc/src
echo "WEBRTC_DIR = $WEBRTC_DIR"

function clearArtifacts() {
	declare -a COMPONENTS=(
		"$OUTPUT_DIR"
		"$BUILD_DIR"
	)
	for COMPONENT in "${COMPONENTS[@]}"
	do
		if [ -d $COMPONENT ]
		then
			echo "Removing dir $COMPONENT"
			rm -rf $COMPONENT
		fi
	done

	if [ "$NO_INTERACTIVE" = false ]; then
		mkdir -p $OUTPUT_DIR
	else
		mkdir -p $OUTPUT_DIR
		mkdir -p $OUTPUT_DIR/simulator
	fi
	echo 'OUTPUT_DIR created'

	mkdir -p $BUILD_DIR
	echo 'BUILD_DIR created'
}

if [ "$ONLY_FETCH_DEPS" = false ] && [ "$NO_INTERACTIVE" = true ]; then
    clearArtifacts
elif [ "$ONLY_FETCH_DEPS" = false ]; then
	while true
	do
		read -n 1 -p "Clear old build artifacts? (Y|n): " INPUT_STRING
		# echo ""
		case $INPUT_STRING in
			n|N)
				echo ""
				break
				;;
			y|Y|"")
				echo ""
				clearArtifacts
				break
				;;
			*)
				echo -ne "\r\033[0K\r"
				tput bel
				;;
		esac
	done
fi

function refetchLibmediasoupclient() {
	echo 'Cloning libmediasoupclient'
	cd $WORK_DIR
	rm -rf libmediasoupclient
	git clone -b vl-m112.2 --depth 1 https://github.com/VLprojects/libmediasoupclient.git
	
	pushd $WORK_DIR/libmediasoupclient 
    git apply $PATCHES_DIR/hybrid_callback.patch
    git apply $PATCHES_DIR/datachannel_open.patch
    popd
}

if [ -d $WORK_DIR/libmediasoupclient ]
then
	echo "libmediasoupclient is already on disk"
	if [ "$NO_INTERACTIVE" = false ] && [ "$ONLY_FETCH_DEPS" = false ]; then
		while true
		do
			read -n 1 -p "Refetch libmediasoupclient (y|N): " INPUT_STRING
			case $INPUT_STRING in
				n|N|"")
					echo ""
					break
					;;
				y|Y)
					echo ""
					refetchLibmediasoupclient
					break
					;;
				*)
					echo -ne "\r\033[0K\r"
					tput bel
					;;
			esac
		done
	fi
else
	refetchLibmediasoupclient
fi

function refetchDepotTools() {
	echo 'Cloning depot_tools'
	cd $WORK_DIR
	rm -rf depot_tools
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
	cd depot_tools
	git checkout 9b4d1e485d37a44e3ebe73a06d21fc79c527ec96
}

if [ -d $WORK_DIR/depot_tools ]
then
	echo "depot_tools is already on disk"
	if [ "$NO_INTERACTIVE" = false ] && [ "$ONLY_FETCH_DEPS" = false ]; then
		while true
		do
			read -n 1 -p "Refetch depot_tools (y|N): " INPUT_STRING
			echo ""
			case $INPUT_STRING in
				n|N|"")
					break
					;;
				y|Y)
					refetchDepotTools
					break
					;;
				*)
					tput bel
					;;
			esac
		done
	fi
else
	if [ "$ONLY_FETCH_DEPS" = false ]; then
		refetchDepotTools
	fi
fi

export PATH=$WORK_DIR/depot_tools:$PATH

function patchWebRTC() {
	echo 'Patching WebRTC for iOS platform support'
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/builtin_audio_decoder_factory.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/builtin_audio_encoder_factory.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/sdp_video_format_utils.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/sdk_BUILD.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/abseil_optional.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/abseil_variant.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/RTCPeerConnectionFactoryBuilder.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/audio_device_module_h.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/audio_device_module_mm.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/objc_video_decoder_factory_h.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/objc_video_encoder_factory_h.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/video_decoder_factory_h.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/video_encoder_factory_h.patch
    patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/objc_audio_device_module_h.patch
    patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/objc_audio_device_module_mm.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/absl_threadlocal.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/task_factory.patch
	patch -b -p0 -d $WORK_DIR < $PATCHES_DIR/metal_header.patch
}

function refetchWebRTC() {
	echo 'Cloning WebRTC'
	rm -rf $WORK_DIR/webrtc
	mkdir -p $WORK_DIR/webrtc
	cd $WORK_DIR/webrtc

	export DEPOT_TOOLS_UPDATE=0
	gclient root
	gclient config --spec \
'solutions = [{
	"name": "src",
	"url": "https://webrtc.googlesource.com/src.git",
	"deps_file": "DEPS",
	"managed": False,
	"custom_deps": {},
}]
target_os = ["ios"]'

	# Fetch WebRTC m94 version.
	# gclient sync --no-history --revision src@branch-heads/4606 
	# Fetch WebRTC m112 version.
	gclient sync --no-history --revision src@branch-heads/5615 

	# Fetch all possible WebRTC versions so you can switch between them.
	# Takes longer time and more disk space.
	# gclient sync --nohooks --with_branch_heads --with_tags

	# Checkout a new version for the first time
	# cd $WORK_DIR/webrtc/src
	# git reset --hard
	# cd $WORK_DIR/webrtc/src/third_party
	# git reset --hard
	# git checkout -b m112 refs/remotes/branch-heads/5615

	# Switch to WebRTC version that already was checked out previously.
	# git checkout m112

	# Run hooks after switching between WebRTC versions.
	# cd $WORK_DIR/webrtc/src
	# gclient sync --no-history -D
}

function resetWebRTC() {
	cd $WORK_DIR/webrtc/src
	git reset --hard
	
	cd $WORK_DIR/webrtc/src/third_party
	git reset --hard
}

if [ "$ONLY_FETCH_DEPS" = true ]; then
	echo "Only fetching dependencies, extracting WebRTC headers"
	echo "Untarring WebRTC-includes.tar.gz..."
	tar -xzf $PROJECT_DIR/bin/WebRTC-includes.tar.gz -C $PROJECT_DIR

else
	if [ -d $WORK_DIR/webrtc ]
	then
		echo "WebRTC is already on disk"
		if [ "$NO_INTERACTIVE" = false ]; then
			while true
			do
				read -n 1 -p "Refetch WebRTC? (f)ull clone | (r)eset local changes | (N)o: " INPUT_STRING
				echo ""
				case $INPUT_STRING in
					n|N|"")
						break
						;;
					f|F)
						refetchWebRTC
						patchWebRTC
						break
						;;
					r|R)
						resetWebRTC
						patchWebRTC
						break
						;;
					*)
						tput bel
						;;
				esac
			done
		else
			resetWebRTC
			patchWebRTC
		fi
	else
		refetchWebRTC
		patchWebRTC
	fi
fi

# Exit early if only fetching dependencies
if [ "$ONLY_FETCH_DEPS" = true ]; then
    echo "Dependencies fetched. Exiting as requested by --only-fetch-deps flag."
    exit 0
fi

# This patch should be applied only after WebRTC is already built.
cd $WEBRTC_DIR
git restore rtc_base/byte_order.h

echo 'Building WebRTC'
cd $WEBRTC_DIR

gn_arguments=(
	'target_os="ios"'
	'ios_deployment_target="14.0"'
	'ios_enable_code_signing=false'
	'is_component_build=false'
	#'is_debug=true'
	'is_debug=false'
	'rtc_libvpx_build_vp9=true'
	'use_goma=false'
	'rtc_enable_symbol_export=true'
	'rtc_enable_objc_symbol_export=true'
	'rtc_enable_protobuf=false'
	'rtc_include_tests=false'
	'rtc_include_builtin_audio_codecs=true'
	'rtc_include_builtin_video_codecs=true'
	'rtc_include_pulse_audio=false'
	'use_rtti=true'
	'use_custom_libcxx=false'
	'use_xcode_clang=true'
	'enable_dsyms=true'
	'enable_stripping=true'
	'treat_warnings_as_errors=false'
)

for str in ${gn_arguments[@]}; do
	gn_args+=" ${str}"
done
platform_args='target_environment="device" target_cpu="arm64"'
gn gen $BUILD_DIR/WebRTC/device/arm64 --ide=xcode --args="${platform_args}${gn_args}"
platform_args='target_environment="simulator" target_cpu="x64"'
gn gen $BUILD_DIR/WebRTC/simulator/x64 --ide=xcode --args="${platform_args}${gn_args}"
platform_args='target_environment="simulator" target_cpu="arm64"'
gn gen $BUILD_DIR/WebRTC/simulator/arm64 --ide=xcode --args="${platform_args}${gn_args}"

cd $BUILD_DIR/WebRTC
ninja -C device/arm64 sdk
ninja -C simulator/x64 sdk
ninja -C simulator/arm64 sdk

cd $BUILD_DIR/WebRTC
rm -rf simulator/WebRTC.framework
rm -rf simulator/WebRTC.dSYM
cp -R simulator/arm64/WebRTC.framework simulator/WebRTC.framework
cp -R simulator/arm64/WebRTC.dSYM simulator/WebRTC.dSYM
rm simulator/WebRTC.framework/WebRTC
lipo -create \
	simulator/arm64/WebRTC.framework/WebRTC \
	simulator/x64/WebRTC.framework/WebRTC \
	-output simulator/WebRTC.framework/WebRTC

lipo -create \
    simulator/arm64/WebRTC.dSYM/Contents/Resources/DWARF/WebRTC \
    simulator/x64/WebRTC.dSYM/Contents/Resources/DWARF/WebRTC \
    -output simulator/WebRTC.dSYM/Contents/Resources/DWARF/WebRTC

cd $BUILD_DIR/WebRTC

if [ "$NO_INTERACTIVE" = false ]; then
	rm -rf $OUTPUT_DIR/WebRTC.xcframework
	xcodebuild -create-xcframework \
		-framework device/arm64/WebRTC.framework \
		-framework simulator/WebRTC.framework \
		-output $OUTPUT_DIR/WebRTC.xcframework
else
	mv device/arm64/WebRTC.framework $OUTPUT_DIR/WebRTC.framework
	mv device/arm64/WebRTC.dSYM $OUTPUT_DIR/WebRTC.dSYM
	mv simulator/WebRTC.framework $OUTPUT_DIR/simulator/WebRTC.framework
	mv simulator/WebRTC.dSYM $OUTPUT_DIR/simulator/WebRTC.dSYM
fi

cd $WORK_DIR

function rebuildLMSC() {
	echo "Building libmediasoupclient"
	rm -rf $BUILD_DIR/libmediasoupclient
	rm -rf $OUTPUT_DIR/sdptransform.xcframework
	rm -rf $OUTPUT_DIR/mediasoupclient.xcframework

	lmsc_cmake_arguments=(
		"-DLIBWEBRTC_INCLUDE_PATH=$WEBRTC_DIR"
		'-DMEDIASOUPCLIENT_LOG_TRACE=OFF'
		'-DMEDIASOUPCLIENT_LOG_DEV=OFF'
		'-DCMAKE_CXX_FLAGS="-fvisibility=hidden"'
		'-DLIBSDPTRANSFORM_BUILD_TESTS=OFF'
		'-DMEDIASOUPCLIENT_BUILD_TESTS=OFF'
		'-DCMAKE_OSX_DEPLOYMENT_TARGET=14'
		'-DCMAKE_BUILD_TYPE=RelWithDebInfo'
		'-DCMAKE_POLICY_VERSION_MINIMUM=3.5'
	)
	for str in ${lmsc_cmake_arguments[@]}; do
		lmsc_cmake_args+=" ${str}"
	done

	# Build mediasoup-client-ios
	cmake . -B $BUILD_DIR/libmediasoupclient/device/arm64 \
		${lmsc_cmake_args} \
		-DLIBWEBRTC_BINARY_PATH=$BUILD_DIR/WebRTC/device/arm64/WebRTC.framework/WebRTC \
		-DIOS_SDK=iphone \
		-DIOS_ARCHS="arm64" \
		-DPLATFORM=OS64 \
		-DCMAKE_OSX_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
	make -C $BUILD_DIR/libmediasoupclient/device/arm64

	cmake . -B $BUILD_DIR/libmediasoupclient/simulator/x64 \
		${lmsc_cmake_args} \
		-DLIBWEBRTC_BINARY_PATH=$BUILD_DIR/WebRTC/simulator/x64/WebRTC.framework/WebRTC \
		-DIOS_SDK=iphonesimulator \
		-DIOS_ARCHS="x86_64" \
		-DPLATFORM=SIMULATOR64 \
		-DCMAKE_OSX_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
	make -C $BUILD_DIR/libmediasoupclient/simulator/x64

	cmake . -B $BUILD_DIR/libmediasoupclient/simulator/arm64 \
		${lmsc_cmake_args} \
		-DLIBWEBRTC_BINARY_PATH=$BUILD_DIR/WebRTC/simulator/arm64/WebRTC.framework/WebRTC \
		-DIOS_SDK=iphonesimulator \
		-DIOS_ARCHS="arm64"\
		-DPLATFORM=SIMULATORARM64 \
		-DCMAKE_OSX_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
	make -C $BUILD_DIR/libmediasoupclient/simulator/arm64

	# Create a FAT libmediasoup / libsdptransform library
	mkdir -p $BUILD_DIR/libmediasoupclient/simulator/fat
	lipo -create \
		$BUILD_DIR/libmediasoupclient/simulator/x64/libmediasoupclient/libmediasoupclient.a \
		$BUILD_DIR/libmediasoupclient/simulator/arm64/libmediasoupclient/libmediasoupclient.a \
		-output $BUILD_DIR/libmediasoupclient/simulator/fat/libmediasoupclient.a
	lipo -create \
		$BUILD_DIR/libmediasoupclient/simulator/x64/libmediasoupclient/libsdptransform/libsdptransform.a \
		$BUILD_DIR/libmediasoupclient/simulator/arm64/libmediasoupclient/libsdptransform/libsdptransform.a \
		-output $BUILD_DIR/libmediasoupclient/simulator/fat/libsdptransform.a

	if [ "$NO_INTERACTIVE" = false ]; then
		xcodebuild -create-xcframework \
			-library $BUILD_DIR/libmediasoupclient/device/arm64/libmediasoupclient/libmediasoupclient.a \
			-library $BUILD_DIR/libmediasoupclient/simulator/fat/libmediasoupclient.a \
			-output $OUTPUT_DIR/mediasoupclient.xcframework
		xcodebuild -create-xcframework \
			-library $BUILD_DIR/libmediasoupclient/device/arm64/libmediasoupclient/libsdptransform/libsdptransform.a \
			-library $BUILD_DIR/libmediasoupclient/simulator/fat/libsdptransform.a \
			-output $OUTPUT_DIR/sdptransform.xcframework
	else
		mv $BUILD_DIR/libmediasoupclient/device/arm64/libmediasoupclient/libmediasoupclient.a $OUTPUT_DIR/libmediasoupclient.a
		mv $BUILD_DIR/libmediasoupclient/device/arm64/libmediasoupclient/libsdptransform/libsdptransform.a $OUTPUT_DIR/libsdptransform.a
		mv $BUILD_DIR/libmediasoupclient/simulator/fat/libmediasoupclient.a $OUTPUT_DIR/simulator/libmediasoupclient.a
		mv $BUILD_DIR/libmediasoupclient/simulator/fat/libsdptransform.a $OUTPUT_DIR/simulator/libsdptransform.a
	fi
}

if [ -d $BUILD_DIR/libmediasoupclient ]
then
	echo "libmediasoupclient is already built"
	if [ "$NO_INTERACTIVE" = false ]; then
	while true
	do
		read -n 1 -p "Rebuild libmediasoupclient (y|N): " INPUT_STRING
		case $INPUT_STRING in
			n|N|"")
				echo ""
				break
				;;
			y|Y)
				echo ""
				rebuildLMSC
				break
				;;
			*)
				echo -ne "\r\033[0K\r"
				tput bel
				;;
			esac
		done
	else
		rebuildLMSC
	fi
else
	rebuildLMSC
fi

if [ "$NO_INTERACTIVE" = false ]; then
	open $PROJECT_DIR/Mediasoup.xcodeproj
fi
