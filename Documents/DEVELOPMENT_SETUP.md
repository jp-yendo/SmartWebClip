# Development Environment Setup

## Prerequisites

### 1. Install Flutter SDK

Download and install Flutter SDK (version 3.0 or later) from the official website:
https://flutter.dev/docs/get-started/install

### 2. Platform-Specific Requirements

#### Windows
- Visual Studio 2022 or later with "Desktop development with C++" workload
- Windows 10 or later

#### macOS
- Xcode 14 or later
- CocoaPods (install via: `sudo gem install cocoapods`)
- macOS 10.15 (Catalina) or later

#### Linux
- CMake
- Ninja build system
- GTK development libraries
- pkg-config

Install on Ubuntu/Debian:
```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

#### Android
- Android Studio or Android SDK
- Android SDK Platform-Tools
- Android SDK Build-Tools
- Android Emulator (optional, for testing)

#### iOS (macOS only)
- Xcode 14 or later
- iOS 12.0 or later
- CocoaPods

## Setup Steps

### 1. Clone the Repository

```bash
git clone <repository-url>
cd SmartWebClip
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Localization Files

```bash
flutter gen-l10n
```

### 4. Platform-Specific Setup

#### Windows
```bash
flutter config --enable-windows-desktop
```

#### macOS
```bash
flutter config --enable-macos-desktop
cd macos
pod install
cd ..
```

#### Linux
```bash
flutter config --enable-linux-desktop
```

#### Android
No additional setup required if Android SDK is properly configured.

#### iOS (macOS only)
```bash
cd ios
pod install
cd ..
```

## Running the Application

### Desktop (Windows, macOS, Linux)
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### Mobile (Android, iOS)
```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios
```

### List Available Devices
```bash
flutter devices
```

## Building for Production

See [BUILD_AND_RELEASE.md](./BUILD_AND_RELEASE.md) for detailed build instructions.

## Troubleshooting

### Flutter Doctor
Run the following command to check your development environment:
```bash
flutter doctor -v
```

### Common Issues

1. **"No devices found"**
   - Make sure you have enabled the target platform
   - For mobile, ensure emulator/device is connected
   - For desktop, check platform-specific requirements

2. **"pub get failed"**
   - Check your internet connection
   - Try running `flutter pub cache repair`

3. **Build errors**
   - Clean the build: `flutter clean`
   - Re-install dependencies: `flutter pub get`
   - Regenerate platform files if needed

## IDE Setup

### Visual Studio Code
1. Install the Flutter extension
2. Install the Dart extension
3. Open the project folder
4. Press F5 to run

### Android Studio / IntelliJ IDEA
1. Install Flutter plugin
2. Install Dart plugin
3. Open the project
4. Select device and click Run

## Code Generation

If you modify model classes or add new localizations:

```bash
# Generate localization files
flutter gen-l10n

# Clean and rebuild
flutter clean
flutter pub get
```
