# Flutter Mobile App Setup Instructions

## Prerequisites

### 1. Install Flutter SDK
1. Download Flutter SDK from [flutter.dev](https://docs.flutter.dev/get-started/install)
2. Extract to a suitable location (e.g., `C:\flutter` on Windows)
3. Add Flutter to your PATH environment variable
4. Run `flutter doctor` to verify installation

### 2. Install Android Studio
1. Download from [developer.android.com](https://developer.android.com/studio)
2. Install with default settings
3. Install Android SDK (API level 21 or higher)
4. Install Android Virtual Device (AVD) for emulator

### 3. Setup Development Environment
1. Open Android Studio
2. Go to File → Settings → Plugins
3. Install Flutter and Dart plugins
4. Restart Android Studio

## Project Setup

### 1. Open Project in Android Studio
1. Open Android Studio
2. Click "Open an existing project"
3. Navigate to the `flutter_app` folder
4. Click "Open"

### 2. Configure Dependencies
1. Open terminal in Android Studio
2. Run the following commands:
```bash
flutter pub get
flutter pub deps
```

### 3. Configure Backend Connection

#### For Android Emulator:
- The app is pre-configured to use `10.0.2.2:8080`
- No changes needed if backend runs on localhost:8080

#### For Physical Device:
1. Find your computer's IP address:
   - Windows: `ipconfig` in Command Prompt
   - Mac/Linux: `ifconfig` in Terminal
2. Update `lib/utils/constants.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_IP_ADDRESS:8080/api';
   ```
3. Ensure your device and computer are on the same network

### 4. Start Backend Server
1. Open terminal in the `alu_backend` folder
2. Run:
```bash
./mvnw spring-boot:run
```
3. Verify server is running at `http://localhost:8080`

## Running the App

### 1. Using Android Emulator
1. In Android Studio, click "AVD Manager"
2. Create a new virtual device (recommended: Pixel 6 with API 33+)
3. Start the emulator
4. In terminal, run:
```bash
flutter run
```

### 2. Using Physical Device
1. Enable Developer Options on your Android device:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
2. Enable USB Debugging in Developer Options
3. Connect device via USB
4. Run:
```bash
flutter run
```

### 3. Using Android Studio IDE
1. Select your target device (emulator or physical)
2. Click the "Run" button (green play icon)
3. Or press Shift+F10

## Building for Release

### 1. Build APK
```bash
flutter build apk --release
```
The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

### 2. Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
The bundle will be generated at: `build/app/outputs/bundle/release/app-release.aab`

### 3. Install APK on Device
```bash
flutter install --release
```

## Troubleshooting

### Common Issues

#### 1. "Unable to connect to backend"
- Verify backend server is running
- Check IP address configuration
- Ensure device and computer are on same network
- Check firewall settings

#### 2. "Gradle build failed"
- Run `flutter clean`
- Run `flutter pub get`
- Restart Android Studio

#### 3. "SDK not found"
- Open Android Studio → SDK Manager
- Install required SDK versions
- Update PATH environment variables

#### 4. "Device not detected"
- Enable USB Debugging on device
- Install device drivers
- Try different USB cable/port

### Performance Issues
- Use Release mode for testing: `flutter run --release`
- Clear app data if experiencing issues
- Restart emulator/device

### Network Issues
- Check internet connectivity
- Verify backend server accessibility
- Test API endpoints using Postman

## Development Tips

### 1. Hot Reload
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Use `flutter run --hot` for automatic hot reload

### 2. Debugging
- Use `print()` statements for logging
- Use Flutter Inspector in Android Studio
- Enable debug mode: `flutter run --debug`

### 3. Testing
- Run unit tests: `flutter test`
- Run integration tests: `flutter test integration_test/`
- Use Flutter Driver for UI testing

### 4. Code Quality
- Run `flutter analyze` for static analysis
- Use `flutter format .` for code formatting
- Follow Dart style guidelines

## Production Deployment

### 1. App Signing
1. Generate keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

3. Update `android/app/build.gradle` with signing config

### 2. Play Store Release
1. Build app bundle: `flutter build appbundle --release`
2. Upload to Google Play Console
3. Complete store listing with screenshots
4. Submit for review

### 3. Internal Distribution
- Use Firebase App Distribution
- Or distribute APK directly to testers

## Maintenance

### 1. Updates
- Regularly update Flutter SDK: `flutter upgrade`
- Update dependencies: `flutter pub upgrade`
- Monitor for security updates

### 2. Monitoring
- Implement crash reporting (Firebase Crashlytics)
- Monitor app performance
- Track user analytics (privacy-compliant)

### 3. Backup
- Regular code backups
- Database backups
- Configuration backups

## Support

For technical support:
- **Email**: support@stjosephstechnology.ac.in
- **Documentation**: Check README.md files
- **Issues**: Create GitHub issues for bugs
- **Community**: Flutter community forums

## Next Steps

1. Test all features thoroughly
2. Optimize performance for production
3. Implement additional security measures
4. Add comprehensive error handling
5. Prepare for Play Store submission
6. Plan for future feature updates

Happy coding! 🚀