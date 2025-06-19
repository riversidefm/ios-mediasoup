For iOS branch - master 

For macOS branch - macos

## If you want to change only Mediasoup, take the next steps:
1. Clone the repo.
2. Make changes for example in Consumer.swift
3. Select the Mediasoup.xcodeproj in Xcode
4. Check the target it must be Mediasoup Framework
5. Run the Framework (cmd+b)

* After the script will finish the task. We can find the updated framework in the bin folder - Mediasoup.xcframework.

6. Push updates

* Next steps you can find here https://github.com/riversidefm/livecalls-client-ios-sdk

## If you want to change WebRTC, take the next steps:

All dependencies (WebRTC, libmediasoupclient, libsdptransform) are prebuilt and added to the repo as binary .xcframework's to reduce application build time. Fetching and building them from scratch takes couple of hours. If your security policy doesn't allow to import binary dependencies, or you just wand to go deeper, you can build everything on your machine.

Dependencies are resolved with one command: .\build.sh. WebRTC sources are fetched from official repo and than patched locally to make it usable on iOS platform and also to expose some missing things. If you want to switch to another WebRTC version, configure WebRTC build flags, or make other customizations, dive into build.sh. We use XCFrameworks to cover both devices and simulators, including simulators on Apple Silicon macs, which is not possible with older .framework format.

### IMPORTANT:
* Need to install python on the Mac
* Need to install ninja on the Mac.

1. Clone the repo
2. Run sh script. For iOS - build_ios.sh. For macOS - build_macos.sh

If you want to make available extra WebRTC Classes, make next:
* In the project go to  patches/sdk_BUILD.patch
* Add class to the deps
3. Re-run sh script


P.S. In the ```SH``` script all functions are described with a comments
