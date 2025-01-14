#! /bin/bash
set -e


SRCROOT=$(pwd)
PROJECT_NAME="Mediasoup"
FRAMEWORK_NAME="Mediasoup"
BUILD_DIR="${SRCROOT}/build/Mediasoup"
OUTPUT_DIR="${SRCROOT}/bin"

# Remove build directory if it exists
if [ -d "${BUILD_DIR}" ]; then
	rm -rf "${BUILD_DIR}"
fi

# Build the framework for both device and simulator
xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${FRAMEWORK_NAME}" \
    -configuration Release \
    -arch arm64 only_active_arch=no \
    -sdk "iphoneos" \
    -derivedDataPath "${BUILD_DIR}"

xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${FRAMEWORK_NAME}" \
    -configuration Release \
    -arch x86_64 -arch arm64 only_active_arch=no \
    -sdk "iphonesimulator" \
    -derivedDataPath "${BUILD_DIR}"

xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${FRAMEWORK_NAME}" \
    -configuration Release \
    -arch arm64 -arch x86_64 only_active_arch=no \
    -sdk "macosx" \
    -derivedDataPath "${BUILD_DIR}"

# Prepare output directory
mkdir -p ${OUTPUT_DIR}
if [ -d "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework" ]; then
	rm -rf "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework"
fi

xcodebuild -create-xcframework \
	-framework ${BUILD_DIR}/Build/Products/Release-iphoneos/${FRAMEWORK_NAME}.framework \
	-framework ${BUILD_DIR}/Build/Products/Release-iphonesimulator/${FRAMEWORK_NAME}.framework \
	-framework ${BUILD_DIR}/Build/Products/Release/${FRAMEWORK_NAME}.framework \
	-output $OUTPUT_DIR/${FRAMEWORK_NAME}.xcframework