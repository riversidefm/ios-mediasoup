# libmediasoup iOS build file

cmake_minimum_required(VERSION 3.5)

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
project(Project)

# C++ requirements
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD REQUIRED ON)

# set mediasoup flags
set(LIBSDPTRANSFORM_BUILD_TESTS OFF)
set(LIBSDPTRANSFORM_BUILD_READMEHELPER OFF)

set(MACOS_SDKVER "13.1")
set(MACOS_VERSION_MIN "13.1")

message(STATUS "\n========== libmediasoupclient macOS Build Configuration ==========\n")
message(STATUS "CMAKE_OSX_SYSROOT             = " ${CMAKE_OSX_SYSROOT})
message(STATUS "CMAKE_OSX_ARCHITECTURES       = " ${CMAKE_OSX_ARCHITECTURES})

# Source dependencies
add_subdirectory("libmediasoupclient")

