# Birthday Buddy

Birthday Buddy keeps birthdays, relationship details, and personal notes on the device. It includes a searchable list, upcoming birthday dashboard, monthly calendar, age/countdown calculations, and optional local reminders.

## Run and Verify

Requires Flutter and the Android SDK. From this directory:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

## Release APK

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. The current Android release configuration uses Flutter's debug signing key, which is suitable for direct installation and testing, but should be replaced with a private release keystore before store distribution.

To install directly when an Android device is connected with USB debugging enabled:

```powershell
flutter install --release
```

Otherwise, transfer the APK to the phone, open it, and approve installation from that file source if Android asks.