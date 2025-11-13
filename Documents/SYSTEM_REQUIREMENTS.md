# System Requirements

## Minimum System Requirements

### Windows
- **Operating System**: Windows 10 (64-bit) or later
- **Processor**: 1 GHz or faster processor
- **Memory**: 4 GB RAM
- **Storage**: 500 MB available space
- **Graphics**: DirectX 9 or later with WDDM 1.0 driver
- **Network**: Internet connection for web scraping and updates

### macOS
- **Operating System**: macOS 10.15 (Catalina) or later
- **Processor**: Intel-based Mac or Apple Silicon (M1/M2)
- **Memory**: 4 GB RAM
- **Storage**: 500 MB available space
- **Network**: Internet connection for web scraping and updates

### Linux
- **Operating System**: Ubuntu 20.04 LTS or later (or equivalent distributions)
- **Processor**: 1 GHz or faster processor
- **Memory**: 4 GB RAM
- **Storage**: 500 MB available space
- **Graphics**: X11 or Wayland display server
- **Network**: Internet connection for web scraping and updates
- **Dependencies**: GTK 3.0 or later

### Android
- **Operating System**: Android 5.0 (Lollipop) or later
- **Processor**: ARMv7 or ARM64
- **Memory**: 2 GB RAM
- **Storage**: 200 MB available space
- **Network**: Internet connection for web scraping and updates

### iOS / iPadOS
- **Operating System**: iOS 12.0 or later / iPadOS 13.0 or later
- **Device**: iPhone 6s or later / iPad (5th generation) or later
- **Memory**: 2 GB RAM
- **Storage**: 200 MB available space
- **Network**: Internet connection for web scraping and updates

---

## Recommended System Requirements

### Windows
- **Operating System**: Windows 11 (64-bit)
- **Processor**: 2 GHz dual-core processor or better
- **Memory**: 8 GB RAM
- **Storage**: 1 GB available space (SSD recommended)
- **Network**: Broadband internet connection

### macOS
- **Operating System**: macOS 13 (Ventura) or later
- **Processor**: Apple Silicon (M1/M2) or Intel Core i5 or better
- **Memory**: 8 GB RAM
- **Storage**: 1 GB available space (SSD recommended)
- **Network**: Broadband internet connection

### Linux
- **Operating System**: Ubuntu 22.04 LTS or later
- **Processor**: 2 GHz dual-core processor or better
- **Memory**: 8 GB RAM
- **Storage**: 1 GB available space (SSD recommended)
- **Network**: Broadband internet connection

### Android
- **Operating System**: Android 10 or later
- **Processor**: Octa-core 2.0 GHz or better
- **Memory**: 4 GB RAM
- **Storage**: 500 MB available space
- **Network**: 4G/5G or Wi-Fi

### iOS / iPadOS
- **Operating System**: iOS 16.0 or later
- **Device**: iPhone 12 or later / iPad Air (4th generation) or later
- **Memory**: 4 GB RAM
- **Storage**: 500 MB available space
- **Network**: 4G/5G or Wi-Fi

---

## Internet Requirements

Smart Web Clip requires an active internet connection for the following features:
- Adding new URLs
- Fetching page titles
- Downloading thumbnails
- Checking for updates (RSS and HTML)
- Opening URLs in browser

Local features (viewing saved URLs, managing collections) work offline.

---

## Browser Compatibility

For the best experience when opening URLs:
- **Windows**: Microsoft Edge, Google Chrome, Firefox
- **macOS**: Safari, Google Chrome, Firefox
- **Linux**: Firefox, Google Chrome, Chromium
- **Android**: Chrome, Firefox
- **iOS**: Safari, Chrome

---

## Database

- Uses SQLite for local data storage
- No external database server required
- Database size depends on the number of URLs stored (typically < 10 MB for 1000 URLs)

---

## Supported Languages

- English
- Japanese (日本語)

Additional languages can be added through localization files.

---

## Known Limitations

1. **Thumbnail capture**: Best-effort feature; may not work for all websites
2. **JavaScript-heavy sites**: May not detect changes on sites that load content dynamically
3. **Authentication**: Does not support checking password-protected pages
4. **Rate limiting**: Some websites may block frequent checks; recommended check interval is 15+ minutes
5. **Large HTML pages**: Pages larger than 10 MB may cause performance issues

---

## Permissions Required

### Android
- Internet access (for fetching web content)
- Storage access (for saving thumbnails and database)

### iOS
- Internet access (for fetching web content)
- Photo library access (optional, for saving thumbnails)

### Desktop (Windows, macOS, Linux)
- Network access (for fetching web content)
- File system access (for saving data and thumbnails)

---

## Support

For issues or questions:
- GitHub Issues: [repository-url]/issues
- Email: support@example.com
