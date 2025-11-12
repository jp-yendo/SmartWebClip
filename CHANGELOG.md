# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - TBD

### Added
- Initial release
- URL management (add, edit, delete, bulk operations)
- Collection management for organizing URLs
- Update checking with three modes:
  - RSS/Atom feed monitoring
  - HTML standard (full page body) change detection
  - HTML custom (CSS selector-based) change detection
- Automatic thumbnail fetching from Open Graph images
- Multi-language support (English and Japanese)
- Cross-platform support (Windows, macOS, Linux, Android, iOS)
- Local SQLite database for data storage
- Material Design 3 UI with dark/light theme support
- Responsive design for all screen sizes

### Technical Features
- State management with Provider
- Localization using Flutter's built-in l10n
- SQLite database with sqflite and sqflite_common_ffi
- HTML parsing with html package
- RSS parsing with webfeed package
- HTTP requests with http package

## [Unreleased]

### Planned Features
- Background update checking
- Push notifications for updates
- Export/import functionality
- Cloud sync (optional)
- Browser extension integration
- More language support
- Advanced filtering and search
- Update history tracking
- Scheduled update checks
- Custom update check intervals per URL
- Statistics and analytics
- Backup and restore
