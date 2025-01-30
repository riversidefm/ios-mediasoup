#!/bin/bash
set -e

# Parse arguments
INCLUDE_DSYM=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --include-dsym)
      INCLUDE_DSYM=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--include-dsym]"
      exit 1
      ;;
  esac
done

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

# Build the xcframework command based on include-dsym flag
XCFRAMEWORK_CMD="xcodebuild -create-xcframework"

if [ "$INCLUDE_DSYM" = true ]; then
    XCFRAMEWORK_CMD+=" -framework $OUTPUT_DIR/mac/WebRTC.framework \
        -debug-symbols $OUTPUT_DIR/mac/WebRTC.dSYM \
        -framework $OUTPUT_DIR/ios/WebRTC.framework \
        -debug-symbols $OUTPUT_DIR/ios/WebRTC.dSYM \
        -framework $OUTPUT_DIR/ios/simulator/WebRTC.framework \
        -debug-symbols $OUTPUT_DIR/ios/simulator/WebRTC.dSYM"
else
    XCFRAMEWORK_CMD+=" -framework $OUTPUT_DIR/mac/WebRTC.framework \
        -framework $OUTPUT_DIR/ios/WebRTC.framework \
        -framework $OUTPUT_DIR/ios/simulator/WebRTC.framework"
fi

XCFRAMEWORK_CMD+=" -output $OUTPUT_DIR/WebRTC.xcframework"
eval "$XCFRAMEWORK_CMD"

# Create tar file with the internal include files from webrtc, compressed
find Mediasoup/dependencies/webrtc/src -name "*.h" -o -name "*.hpp" | tar -zcf $OUTPUT_DIR/WebRTC-includes.tar.gz -T -

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