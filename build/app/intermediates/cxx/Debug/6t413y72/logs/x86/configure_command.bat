@echo off
"D:\\o D\\Android SDK\\cmake\\3.22.1\\bin\\cmake.exe" ^
  "-HD:\\o D\\Flutter\\packages\\flutter_tools\\gradle\\src\\main\\groovy" ^
  "-DCMAKE_SYSTEM_NAME=Android" ^
  "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" ^
  "-DCMAKE_SYSTEM_VERSION=21" ^
  "-DANDROID_PLATFORM=android-21" ^
  "-DANDROID_ABI=x86" ^
  "-DCMAKE_ANDROID_ARCH_ABI=x86" ^
  "-DANDROID_NDK=D:\\o D\\Android SDK\\ndk\\26.3.11579264" ^
  "-DCMAKE_ANDROID_NDK=D:\\o D\\Android SDK\\ndk\\26.3.11579264" ^
  "-DCMAKE_TOOLCHAIN_FILE=D:\\o D\\Android SDK\\ndk\\26.3.11579264\\build\\cmake\\android.toolchain.cmake" ^
  "-DCMAKE_MAKE_PROGRAM=D:\\o D\\Android SDK\\cmake\\3.22.1\\bin\\ninja.exe" ^
  "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=D:\\Hoc\\LTDD\\Bai3\\doanltdd\\build\\app\\intermediates\\cxx\\Debug\\6t413y72\\obj\\x86" ^
  "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=D:\\Hoc\\LTDD\\Bai3\\doanltdd\\build\\app\\intermediates\\cxx\\Debug\\6t413y72\\obj\\x86" ^
  "-DCMAKE_BUILD_TYPE=Debug" ^
  "-BD:\\Hoc\\LTDD\\Bai3\\doanltdd\\android\\app\\.cxx\\Debug\\6t413y72\\x86" ^
  -GNinja ^
  -Wno-dev ^
  --no-warn-unused-cli
