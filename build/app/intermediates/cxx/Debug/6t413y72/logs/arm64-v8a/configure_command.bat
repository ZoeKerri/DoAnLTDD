@echo off
"D:\\o D\\Android SDK\\cmake\\3.22.1\\bin\\cmake.exe" ^
  "-HD:\\o D\\Flutter\\packages\\flutter_tools\\gradle\\src\\main\\groovy" ^
  "-DCMAKE_SYSTEM_NAME=Android" ^
  "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" ^
  "-DCMAKE_SYSTEM_VERSION=21" ^
  "-DANDROID_PLATFORM=android-21" ^
  "-DANDROID_ABI=arm64-v8a" ^
  "-DCMAKE_ANDROID_ARCH_ABI=arm64-v8a" ^
  "-DANDROID_NDK=D:\\o D\\Android SDK\\ndk\\26.3.11579264" ^
  "-DCMAKE_ANDROID_NDK=D:\\o D\\Android SDK\\ndk\\26.3.11579264" ^
  "-DCMAKE_TOOLCHAIN_FILE=D:\\o D\\Android SDK\\ndk\\26.3.11579264\\build\\cmake\\android.toolchain.cmake" ^
  "-DCMAKE_MAKE_PROGRAM=D:\\o D\\Android SDK\\cmake\\3.22.1\\bin\\ninja.exe" ^
  "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=D:\\Hoc\\LTDD\\Bai3\\doanltdd\\build\\app\\intermediates\\cxx\\Debug\\6t413y72\\obj\\arm64-v8a" ^
  "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=D:\\Hoc\\LTDD\\Bai3\\doanltdd\\build\\app\\intermediates\\cxx\\Debug\\6t413y72\\obj\\arm64-v8a" ^
  "-DCMAKE_BUILD_TYPE=Debug" ^
  "-BD:\\Hoc\\LTDD\\Bai3\\doanltdd\\android\\app\\.cxx\\Debug\\6t413y72\\arm64-v8a" ^
  -GNinja ^
  -Wno-dev ^
  --no-warn-unused-cli
