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

# Build for arm64
xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "${FRAMEWORK_NAME}" \
        -configuration Release \
        -arch arm64 only_active_arch=no \
        -sdk "macosx" \
        -derivedDataPath "${BUILD_DIR}/arm64"

# Build for x86_64
xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "${FRAMEWORK_NAME}" \
        -configuration Release \
        -arch x86_64 only_active_arch=no \
        -sdk "macosx" \
        -derivedDataPath "${BUILD_DIR}/x86_64"
# Create output directory
mkdir -p "${BUILD_DIR}/Build/Products/Release"

# Copy framework and dSYM from arm64 build as base
cp -R "${BUILD_DIR}/arm64/Build/Products/Release/${FRAMEWORK_NAME}.framework" "${BUILD_DIR}/Build/Products/Release/"
cp -R "${BUILD_DIR}/arm64/Build/Products/Release/${FRAMEWORK_NAME}.framework.dSYM" "${BUILD_DIR}/Build/Products/Release/"

# Create universal binary with lipo for framework
lipo -create \
    "${BUILD_DIR}/arm64/Build/Products/Release/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" \
    "${BUILD_DIR}/x86_64/Build/Products/Release/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" \
    -output "${BUILD_DIR}/Build/Products/Release/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

# Create universal binary with lipo for dSYM
lipo -create \
    "${BUILD_DIR}/arm64/Build/Products/Release/${FRAMEWORK_NAME}.framework.dSYM/Contents/Resources/DWARF/${FRAMEWORK_NAME}" \
    "${BUILD_DIR}/x86_64/Build/Products/Release/${FRAMEWORK_NAME}.framework.dSYM/Contents/Resources/DWARF/${FRAMEWORK_NAME}" \
    -output "${BUILD_DIR}/Build/Products/Release/${FRAMEWORK_NAME}.framework.dSYM/Contents/Resources/DWARF/${FRAMEWORK_NAME}"

# Copy the relocations folder from the x86_64 build
cp -R "${BUILD_DIR}/x86_64/Build/Products/Release/${FRAMEWORK_NAME}.framework.dSYM/Contents/Resources/Relocations/" "${BUILD_DIR}/Build/Products/Release/${FRAMEWORK_NAME}.framework.dSYM/Contents/Resources/Relocations/"

# Prepare output directory
mkdir -p ${OUTPUT_DIR}
if [ -d "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework" ]; then
	rm -rf "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework"
fi

xcodebuild -create-xcframework \
	-framework ${BUILD_DIR}/Build/Products/Release-iphoneos/${FRAMEWORK_NAME}.framework \
    -debug-symbols ${BUILD_DIR}/Build/Products/Release-iphoneos/${FRAMEWORK_NAME}.framework.dSYM \
	-framework ${BUILD_DIR}/Build/Products/Release-iphonesimulator/${FRAMEWORK_NAME}.framework \
    -debug-symbols ${BUILD_DIR}/Build/Products/Release-iphonesimulator/${FRAMEWORK_NAME}.framework.dSYM \
	-framework ${BUILD_DIR}/Build/Products/Release/${FRAMEWORK_NAME}.framework \
    -debug-symbols ${BUILD_DIR}/Build/Products/Release/${FRAMEWORK_NAME}.framework.dSYM \
	-output $OUTPUT_DIR/${FRAMEWORK_NAME}.xcframework