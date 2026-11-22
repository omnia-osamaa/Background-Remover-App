# Platform setup

Run `flutter create . --project-name bg_remover --org com.omnia` first so the `android/` and `ios/` folders exist, then apply the changes below.

## Android

`android/app/src/main/AndroidManifest.xml`, inside `<manifest>` (before `<application>`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29"/>
```

`android/app/build.gradle` (or `build.gradle.kts`): make sure `minSdk` is at least **21**.

## iOS

`ios/Runner/Info.plist`, inside the main `<dict>`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photos so you can remove their background.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need permission to save your edited images to your gallery.</string>
<key>NSCameraUsageDescription</key>
<string>We need the camera so you can take a photo to edit.</string>
```

`ios/Podfile`: set `platform :ios, '13.0'` (or higher).

## Optional: real background removal

```bash
flutter run --dart-define=REMOVE_BG_API_KEY=your_key
```
