# libmediasoup iOS build file

cmake_minimum_required(VERSION 3.5)

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
project(Project)

# C++ requirements
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD REQUIRED ON)

# set iOS version variables
function(set_ios_version_variables)
    set(IPHONE_SDKVER "14.0" PARENT_SCOPE)
    set(IPHONE_VERSION_MIN "14.0" PARENT_SCOPE)
endfunction()

# set macOS version variables
function(set_macos_version_variables)
    set(MACOS_SDKVER "13.1" PARENT_SCOPE)
    set(MACOS_VERSION_MIN "13.1" PARENT_SCOPE)
endfunction()


# Set the sdk to build with
if("${IOS_SDK}" STREQUAL "iphone")
  set(CMAKE_OSX_SYSROOT "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/")
  # set the ios architectures
  set(CMAKE_OSX_ARCHITECTURES ${IOS_ARCHS})
  set_ios_version_variables()
elseif("${IOS_SDK}" STREQUAL "iphonesimulator")
  set(CMAKE_OSX_SYSROOT "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk")
  # set the ios architectures
  set(CMAKE_OSX_ARCHITECTURES ${IOS_ARCHS})
  set_ios_version_variables()
else()
  set_macos_version_variables()
endif()

# set mediasoup flags
set(LIBSDPTRANSFORM_BUILD_TESTS OFF)
set(LIBSDPTRANSFORM_BUILD_READMEHELPER OFF)

message(STATUS "\n========== libmediasoupclient Build Configuration ==========\n")
message(STATUS "CMAKE_OSX_SYSROOT             = " ${CMAKE_OSX_SYSROOT})
message(STATUS "CMAKE_OSX_ARCHITECTURES       = " ${CMAKE_OSX_ARCHITECTURES})

# Source dependencies
add_subdirectory("libmediasoupclient")
