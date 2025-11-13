# Smart Web Clip

A cross-platform web update monitoring application that helps you track changes to your favorite websites.

![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Android%20%7C%20iOS-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)

[日本語版 README](README-ja.md)

## Features

### 📋 URL Management
- Add and organize your favorite web pages
- Auto-fetch page titles
- Smart high-quality thumbnail fetching:
  - Open Graph images (256-512px optimal range)
  - PWA manifest icons with resolution validation
  - Optional WebView screenshot (platform-dependent)
- Support for RSS feeds and HTML change detection
- Categorize URLs into collections
- Bulk operations (add to collection, delete)

### 🔄 Update Checking
- **RSS Mode**: Monitor RSS/Atom feeds for new articles
- **HTML Standard Mode**: Detect changes to entire page body
- **HTML Custom Mode**: Monitor specific elements using CSS selectors
- Manual and automatic update checks
- Track last checked and last updated timestamps

### 📁 Collection Management
- Group URLs into collections for better organization
- Reorder collections with drag-and-drop
- Filter URLs by collection or view uncategorized items

### 🌐 Multilingual Support
- English and Japanese supported out of the box
- Follows system language settings
- Easy language switching in settings

### 🎨 Modern UI
- Clean and intuitive Material Design 3 interface
- Responsive design for all screen sizes
- Dark and light theme support
- Smooth animations and transitions

### 💾 Local Storage
- All data stored locally using SQLite
- No external dependencies or cloud services required
- Fast and efficient database operations

## Screenshots

*(Add screenshots here)*

## Installation

### Download Pre-built Binaries

Download the latest release for your platform:
- [Windows](https://github.com/your-repo/releases)
- [macOS](https://github.com/your-repo/releases)
- [Linux](https://github.com/your-repo/releases)
- [Android APK](https://github.com/your-repo/releases)
- iOS: Available on App Store *(coming soon)*

### Build from Source

See [DEVELOPMENT_SETUP.md](Documents/DEVELOPMENT_SETUP.md) for detailed instructions.

Quick start:
```bash
# Clone the repository
git clone https://github.com/your-repo/SmartWebClip.git
cd SmartWebClip

# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run on your platform
flutter run -d <device>
```

## Usage

### Adding a URL

1. Click the **+** button
2. Enter the URL
3. (Optional) Enter a custom title or let it auto-fetch
4. Choose update check type:
   - **RSS**: For sites with RSS/Atom feeds
   - **HTML Standard**: For general web pages
   - **HTML Custom**: For monitoring specific page elements
5. Click **Save**

### Checking for Updates

- **Manual**: Click the refresh button in the toolbar
- **Single URL**: Open the URL details and check individually

### Organizing with Collections

1. Go to the **Collections** tab
2. Create a new collection
3. Add URLs to collections using:
   - Bulk selection in URL list
   - Individual URL edit screen

### Changing Language

1. Go to **Settings** tab
2. Tap **Language**
3. Select your preferred language

## System Requirements

See [SYSTEM_REQUIREMENTS.md](Documents/SYSTEM_REQUIREMENTS.md) for detailed requirements.

**Minimum:**
- Windows 10, macOS 10.15, Ubuntu 20.04, Android 5.0, or iOS 12.0
- 4 GB RAM
- 500 MB storage
- Internet connection

## Documentation

- [Development Setup](Documents/DEVELOPMENT_SETUP.md) | [日本語](Documents/DEVELOPMENT_SETUP-ja.md)
- [Build and Release Guide](Documents/BUILD_AND_RELEASE.md) | [日本語](Documents/BUILD_AND_RELEASE-ja.md)
- [System Requirements](Documents/SYSTEM_REQUIREMENTS.md) | [日本語](Documents/SYSTEM_REQUIREMENTS-ja.md)
- [Testing Guide](Documents/TESTING.md) | [日本語](Documents/TESTING-ja.md)

## Technology Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **Database**: SQLite (sqflite)
- **State Management**: Provider
- **HTTP Client**: http package
- **HTML Parser**: html package
- **RSS Parser**: webfeed package

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Contributors and testers
- Open source community

## Support

- **Issues**: [GitHub Issues](https://github.com/your-repo/SmartWebClip/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-repo/SmartWebClip/discussions)
- **Email**: support@example.com

## Roadmap

- [ ] Background update checking
- [ ] Push notifications for updates
- [ ] Export/import functionality
- [ ] Cloud sync (optional)
- [ ] Browser extension integration
- [ ] More language support
- [ ] Advanced filtering and search
- [ ] Update history tracking

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.

---

Made with ❤️ using Flutter