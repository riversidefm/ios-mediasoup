#!/bin/bash
set -e

export PROJECT_DIR=$(pwd)
echo "PROJECT_DIR = $PROJECT_DIR"
export BUILD_DIR=$(pwd)/build
echo "BUILD_DIR = $BUILD_DIR"
export OUTPUT_DIR=$(pwd)/bin
echo "OUTPUT_DIR = $OUTPUT_DIR"

./build_ios.sh --no-interactive
./build_macos.sh --no-interactive

echo "create WebRTC.xcframework"
rm -rf $OUTPUT_DIR/WebRTC.xcframework
xcodebuild -create-xcframework \
    -framework $OUTPUT_DIR/mac/WebRTC.framework \
    -framework $OUTPUT_DIR/ios/WebRTC.framework \
    -framework $OUTPUT_DIR/ios/simulator/WebRTC.framework \
    -output $OUTPUT_DIR/WebRTC.xcframework

echo "create mediasoupclient.xcframework"
rm -rf $OUTPUT_DIR/mediasoupclient.xcframework
xcodebuild -create-xcframework \
    -library $OUTPUT_DIR/mac/libmediasoupclient.a \
    -library $OUTPUT_DIR/ios/libmediasoupclient.a \
    -library $OUTPUT_DIR/ios/simulator/libmediasoupclient.a \
    -output $OUTPUT_DIR/mediasoupclient.xcframework


echo " create sdptransform.xcframework"
rm -rf $OUTPUT_DIR/sdptransform.xcframework
xcodebuild -create-xcframework \
    -library $OUTPUT_DIR/mac/libsdptransform.a \
    -library $OUTPUT_DIR/ios/libsdptransform.a \
    -library $OUTPUT_DIR/ios/simulator/libsdptransform.a \
    -output $OUTPUT_DIR/sdptransform.xcframework

./build_bindings.sh