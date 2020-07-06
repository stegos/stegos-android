
# Stegos Mobile Wallet

## Buidling and testing

### Prerequirements
To build mobile application you should have OS that support Android SDK version 21 and greater.

### Installing requirements:

1. Install Android SDK:

a) You can download it in [Android Studio](https://developer.android.com/studio) bundle. And install emulator and ndk from it. (The instruction will vary from version to version, so main thing that you need to know, is that we use api version 21, and need emulator in order to test app.)

b) Or use ci-script in stegos node repository. To use script, just go to `stegos` root directory and type `WITH_ANDROID=1 ./ci-scripts/build.sh builddep` in terminal. This will install all dependencies needed for building android lib.

2. Installing flutter, you can use https://flutter.dev/docs/get-started/install, or package from your repository, for example in arch linux you can download it from aur package https://aur.archlinux.org/packages/flutter/
3. After installing flutter, check it, using `flutter doctor` command.

Note: If `flutter doctor` report android sdk missing, try to specify android path using enviroment variable, like `export ANDROID_HOME=/opt/android-sdk/`

## Building android application:

1. Getting stegos node library. 

a) You can download it from https://github.com/stegos/stegos/releases.

b) Or build it from sources using ci-scripts.
To build it from source go to the `stegos` root directory and type `WITH_ANDROID=1 ./ci-scripts/build.sh build_release android-x64`
for x86-64 and emulator, or type `WITH_ANDROID=1 ./ci-scripts/build.sh build_release android-aarch64`
for arm-64 version.After this command library should be located in `release` subfolder

2. Copy library to android bundle.

The path is `<stegos-android>/android/app/src/main/jniLibs/arm64-v8a/` for arm-64 version, and `<stegos-android>/android/app/src/main/jniLibs/x86_64/`
3. As last step build android-wallet using `flutter build apk --split-per-abi` command. Flutter should report where to find apk. In my case it report:

```
> flutter build apk --split-per-abi 
Removed unused resources: Binary resource data reduced from 712KB to 709KB: Removed 0%
Removed unused resources: Binary resource data reduced from 712KB to 709KB: Removed 0%
Running Gradle task 'assembleRelease'...                                
Running Gradle task 'assembleRelease'... Done                      11,6s
✓ Built build/app/outputs/apk/release/app-arm64-v8a-release.apk (16.0MB).
✓ Built build/app/outputs/apk/release/app-x86_64-release.apk (16.6MB).
```

So, in order to run it, i should transfer needed apk file to device or emulator.

## Testing application
Flutter allows you to test your application on different devices, it could be emulator, or real connected devices.
In order to start application first you need to connect you device, or install emulator using android-studio.
Then, to start emulator in flutter you should use command `flutter  emulator --launch <Emulator_id>`.

Check `flutter doctor`, it should report that no issues was found, and atleast one device or emulator is found.
```
 flutter doctor                                     
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, v1.17.3, on Linux, locale ru_UA.UTF-8)
[✓] Android toolchain - develop for Android devices (Android SDK version 29.0.2)
[✓] Android Studio (version 3.5)
[✓] Connected device (1 available)

• No issues found!
```

After this done, you can use `flutter run` command in order to start stegos-android application on selected device.

To check stegos library logs, you can use `adb logcat`, for example, in order to filter only stegos related string you can use pwoer of grep: `adb logcat | grep "stegos"`.
This command will stream all log events related to stegos application into your stdin.

