# Testing Guide

## Running Tests

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Platform-Specific Tests

#### Windows
```bash
flutter test -d windows
```

#### macOS
```bash
flutter test -d macos
```

#### Linux
```bash
flutter test -d linux
```

#### Android
```bash
flutter test -d android
```

#### iOS
```bash
flutter test -d ios
```

---

## Test Coverage

Generate test coverage report:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

Open `coverage/html/index.html` in a browser to view the report.

---

## Manual Testing Checklist

### URL Management
- [ ] Add URL with auto-fetched title
- [ ] Add URL with custom title
- [ ] Add URL with RSS check type
- [ ] Add URL with HTML standard check type
- [ ] Add URL with HTML custom check type
- [ ] Edit URL details
- [ ] Delete single URL
- [ ] Delete multiple URLs
- [ ] View URL list (all, by collection, uncategorized)
- [ ] Sort URLs by updated date
- [ ] Sort URLs by added date
- [ ] Sort URLs by title

### Collection Management
- [ ] Create new collection
- [ ] Rename collection
- [ ] Delete collection
- [ ] Reorder collections
- [ ] Add URLs to collection
- [ ] Remove URLs from collection
- [ ] Add multiple URLs to collection at once
- [ ] Filter URLs by collection

### Update Checking
- [ ] Manual update check for single URL
- [ ] Manual update check for all URLs
- [ ] RSS feed detection
- [ ] HTML standard change detection
- [ ] HTML custom selector change detection
- [ ] Error handling for invalid URLs
- [ ] Error handling for network failures

### Thumbnails
- [ ] Auto-capture thumbnail on URL add
- [ ] Retake thumbnail for existing URL
- [ ] Display thumbnail in URL card
- [ ] Handle missing thumbnails gracefully

### Settings
- [ ] Change language to English
- [ ] Change language to Japanese
- [ ] Language persists after app restart
- [ ] UI updates immediately after language change

### UI/UX
- [ ] Responsive layout on different screen sizes
- [ ] Navigation between screens
- [ ] Proper error messages
- [ ] Loading indicators
- [ ] Empty state messages
- [ ] Confirmation dialogs
- [ ] Dark mode support (system theme)
- [ ] Light mode support

### Data Persistence
- [ ] Data persists after app restart
- [ ] Database migrations work correctly
- [ ] No data corruption

### Performance
- [ ] App starts quickly
- [ ] Smooth scrolling in URL list
- [ ] No lag when adding URLs
- [ ] Efficient memory usage
- [ ] No memory leaks

---

## Test Scenarios

### Scenario 1: First-Time User
1. Launch app
2. See empty state
3. Add first URL
4. See URL in list
5. Create first collection
6. Add URL to collection

### Scenario 2: Regular User
1. Launch app
2. View URL list
3. Check for updates
4. View updated URLs
5. Open URL in browser
6. Edit URL details

### Scenario 3: Power User
1. Add multiple URLs
2. Create multiple collections
3. Organize URLs into collections
4. Use bulk actions
5. Change language
6. Sort and filter URLs

### Scenario 4: Error Handling
1. Add invalid URL
2. Handle network error
3. Handle website timeout
4. Handle invalid RSS feed
5. Handle invalid CSS selector

---

## Accessibility Testing

- [ ] Screen reader support
- [ ] Keyboard navigation
- [ ] High contrast mode
- [ ] Font scaling
- [ ] Touch target sizes (mobile)

---

## Localization Testing

### English
- [ ] All UI text in English
- [ ] Date formatting
- [ ] Number formatting
- [ ] Pluralization

### Japanese
- [ ] All UI text in Japanese
- [ ] Date formatting
- [ ] Number formatting
- [ ] Pluralization

---

## Platform-Specific Testing

### Windows
- [ ] Window resizing
- [ ] Minimize/Maximize
- [ ] Multi-monitor support
- [ ] High DPI support

### macOS
- [ ] Window resizing
- [ ] Full screen mode
- [ ] Mission Control compatibility
- [ ] Retina display support

### Linux
- [ ] Window resizing
- [ ] Different desktop environments (GNOME, KDE, XFCE)
- [ ] Wayland vs X11

### Android
- [ ] Different screen sizes
- [ ] Tablet support
- [ ] Back button behavior
- [ ] App lifecycle (pause/resume)
- [ ] Permissions handling

### iOS
- [ ] Different screen sizes (iPhone, iPad)
- [ ] Safe area handling
- [ ] Dark mode
- [ ] App lifecycle
- [ ] Permissions handling

---

## Performance Testing

### Load Testing
- Test with 10 URLs
- Test with 100 URLs
- Test with 1000 URLs
- Test with 10 collections
- Test with 100 collections

### Network Testing
- Test with slow network
- Test with intermittent connection
- Test with no connection
- Test with large web pages

### Memory Testing
- Monitor memory usage during normal operation
- Check for memory leaks
- Test with limited memory

---

## Regression Testing

Run full test suite before each release to ensure no regressions.

Create automated regression test suite for critical paths.

---

## Bug Reporting

When reporting bugs, include:
1. Platform and OS version
2. App version
3. Steps to reproduce
4. Expected behavior
5. Actual behavior
6. Screenshots/logs if applicable
