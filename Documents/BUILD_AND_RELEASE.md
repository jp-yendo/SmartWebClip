# Build and Release Guide

## Building for Production

### Windows

#### 1. Build Release Version
```bash
flutter build windows --release
```

The output will be in: `build/windows/runner/Release/`

#### 2. Create Installer (Optional)
You can use Inno Setup or NSIS to create an installer package.

Example with Inno Setup:
1. Install Inno Setup: https://jrsoftware.org/isinfo.php
2. Create an `.iss` script file
3. Compile the installer

#### 3. Distribution
- Distribute the entire `Release` folder as a ZIP file, or
- Create an installer package

---

### macOS

#### 1. Build Release Version
```bash
flutter build macos --release
```

The output will be in: `build/macos/Build/Products/Release/`

#### 2. Code Signing (Required for Distribution)
```bash
# Sign the app
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name (Team ID)" \
  "build/macos/Build/Products/Release/Smart Web Clip.app"

# Verify signature
codesign --verify --deep --verbose=2 \
  "build/macos/Build/Products/Release/Smart Web Clip.app"
```

#### 3. Create DMG (Optional)
Use `create-dmg` or a similar tool to create a DMG installer.

#### 4. Notarization (Required for macOS 10.15+)
Submit the app to Apple for notarization:
```bash
# Create a ZIP of the app
ditto -c -k --keepParent \
  "build/macos/Build/Products/Release/Smart Web Clip.app" \
  SmartWebClip.zip

# Submit for notarization
xcrun altool --notarize-app \
  --primary-bundle-id "com.example.smartwebclip" \
  --username "your-apple-id@example.com" \
  --password "@keychain:AC_PASSWORD" \
  --file SmartWebClip.zip
```

#### 5. Distribution
- Mac App Store, or
- Direct download from your website

---

### Linux

#### 1. Build Release Version
```bash
flutter build linux --release
```

The output will be in: `build/linux/x64/release/bundle/`

#### 2. Create Package

##### Snap Package
```bash
# Install snapcraft
sudo snap install snapcraft --classic

# Create snap
snapcraft
```

##### AppImage
Use `appimagetool` to create an AppImage package.

##### Flatpak
Create a Flatpak manifest and build with `flatpak-builder`.

#### 3. Distribution
- Snap Store
- Flathub
- Direct download as tarball

---

### Android

#### 1. Configure Signing

Create `android/key.properties`:
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=<your-key-alias>
storeFile=<path-to-keystore>
```

Generate keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

#### 2. Build APK
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

#### 3. Build App Bundle (for Google Play)
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

#### 4. Distribution
- Google Play Store
- Direct APK download
- Third-party app stores

---

### iOS

#### 1. Configure Signing
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner project
3. Go to Signing & Capabilities
4. Select your development team
5. Configure provisioning profile

#### 2. Build for Release
```bash
flutter build ios --release
```

#### 3. Create Archive
1. Open Xcode
2. Product → Archive
3. Wait for the archive to complete

#### 4. Upload to App Store
1. In Xcode Organizer, select the archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Follow the wizard

#### 5. Distribution
- App Store only (iOS doesn't allow sideloading for regular users)

---

## Version Management

### Update Version Number

Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

Format: `major.minor.patch+build`

### Generate Release Notes

Create release notes for each version in your store listing or release page.

---

## Testing Before Release

1. **Functional Testing**
   - Test all features
   - Test on different screen sizes
   - Test locale switching

2. **Performance Testing**
   - Check memory usage
   - Check startup time
   - Test with large datasets

3. **Platform-Specific Testing**
   - Test on minimum supported OS version
   - Test on latest OS version

---

## Store Requirements

### Google Play Store
- Privacy Policy URL
- App icon (512x512 PNG)
- Feature graphic (1024x500 PNG)
- Screenshots (minimum 2)
- Content rating questionnaire
- Target API level 33+ (Android 13+)

### Apple App Store
- Privacy Policy URL
- App icon (1024x1024 PNG)
- Screenshots for all supported device sizes
- App Store description
- Keywords
- Age rating

### Microsoft Store (Windows)
- Privacy Policy URL
- App icon (various sizes)
- Screenshots
- Age rating
- Content descriptors

---

## Continuous Integration

Consider setting up CI/CD for automated builds:
- GitHub Actions
- GitLab CI/CD
- Bitrise
- Codemagic

Example GitHub Actions workflow: see `.github/workflows/build.yml`
