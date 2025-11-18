# Aphasia Speech Therapy - iOS App

<div align="center">
  <img src="https://img.shields.io/badge/iOS-16.0+-blue.svg" alt="iOS 16.0+">
  <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" alt="Swift 5.0">
  <img src="https://img.shields.io/badge/SwiftUI-3.0-green.svg" alt="SwiftUI 3.0">
  <img src="https://img.shields.io/badge/Platform-iPhone%20%7C%20iPad-lightgrey.svg" alt="Platform">
</div>

A native iOS application for aphasia speech therapy, designed for both iPhone and iPad. Built with SwiftUI and modern iOS development practices.

## 📱 Features

### Core Functionality
- **Interactive Therapy Sessions**: Engage with various exercise types including word naming, sentence completion, comprehension, reading, and writing
- **Progress Tracking**: Comprehensive analytics and visualization of therapy progress
- **Multi-language Support**: Full support for English and Polish (Polski)
- **Universal App**: Optimized layouts for both iPhone and iPad
- **Offline Capability**: Continue therapy sessions without internet connection
- **User Authentication**: Secure login and registration with JWT tokens
- **Profile Management**: Customize settings and preferences

### Exercise Types
- 🗣️ **Word Naming**: Practice naming objects and concepts
- ✍️ **Sentence Completion**: Fill in missing words in sentences
- 👂 **Comprehension**: Test understanding of spoken/written content
- 🔄 **Repetition**: Practice repeating words and phrases
- 📖 **Reading**: Reading comprehension exercises
- 📝 **Writing**: Practice writing skills

### User Interface
- Clean, accessible design following iOS Human Interface Guidelines
- Adaptive layouts for different screen sizes
- Dark mode support (coming soon)
- Haptic feedback for enhanced interaction
- Voice-over accessibility support

## 🏗️ Architecture

### Project Structure

```
iOS/AphasiaTherapy/
├── AphasiaTherapyApp.swift       # App entry point
├── ContentView.swift              # Root view
├── Models/                        # Data models
│   ├── User.swift                # User and authentication models
│   ├── TherapySession.swift      # Session and exercise models
│   └── Progress.swift            # Progress tracking models
├── Views/                         # SwiftUI views
│   ├── AuthenticationView.swift  # Login/registration
│   ├── MainTabView.swift         # Main tab navigation
│   ├── HomeView.swift            # Home dashboard
│   ├── SessionsView.swift        # Browse sessions
│   ├── ProgressView.swift        # Progress tracking
│   ├── ProfileView.swift         # User profile
│   └── ExerciseSessionView.swift # Exercise interface
├── ViewModels/                    # View models (MVVM pattern)
├── Services/                      # Business logic layer
│   ├── APIClient.swift           # Network layer
│   ├── AuthenticationManager.swift # Auth management
│   └── LocalizationManager.swift # i18n support
├── Utilities/                     # Helper utilities
│   ├── DeviceHelper.swift        # Device-specific helpers
│   └── Extensions.swift          # Swift extensions
├── Resources/                     # Assets and resources
│   └── Assets.xcassets/          # Images and colors
├── Localization/                  # Translation files
└── Info.plist                     # App configuration

```

### Design Patterns
- **MVVM (Model-View-ViewModel)**: Separation of concerns
- **Repository Pattern**: Data access abstraction
- **Dependency Injection**: Using `@EnvironmentObject`
- **Reactive Programming**: Combine framework for data flow
- **Coordinator Pattern**: Navigation management

## 🚀 Getting Started

### Prerequisites

- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later
- **iOS SDK**: 16.0 or later
- **Apple Developer Account**: For device testing (optional for simulator)

### Installation

1. **Clone the repository:**
   ```bash
   cd iOS
   ```

2. **Open the project:**
   ```bash
   open AphasiaTherapy.xcodeproj
   ```

3. **Configure backend URL:**

   Edit `Services/APIClient.swift` to point to your backend:
   ```swift
   init(baseURL: String = "http://your-backend-url:8000") {
       self.baseURL = baseURL
       // ...
   }
   ```

4. **Select target device:**
   - Choose iPhone or iPad simulator from the Xcode toolbar
   - Or connect a physical device

5. **Build and run:**
   - Press `⌘ + R` or click the Run button
   - The app will build and launch

### Backend Setup

The iOS app requires the FastAPI backend to be running. See the main README for backend setup instructions.

**For local development:**
```bash
# In the backend directory
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m app.main
```

The backend will run at `http://localhost:8000`

**For iOS Simulator:**
- Use `http://localhost:8000`

**For Physical Device:**
- Use your computer's local IP: `http://192.168.x.x:8000`
- Ensure both devices are on the same network
- Update `Info.plist` to allow insecure HTTP (for development only)

## 📱 Building for Device

### Development Build

1. **Connect your iPhone or iPad**
2. **Select your device** in Xcode's toolbar
3. **Configure signing:**
   - Select the project in Navigator
   - Go to "Signing & Capabilities"
   - Select your Team
   - Xcode will automatically provision the app
4. **Build and Run** (`⌘ + R`)

### App Store Build

1. **Update version and build number:**
   ```
   Version: 1.0.0
   Build: 1
   ```

2. **Configure release settings:**
   - Set "Debug" to "Release"
   - Ensure proper code signing certificates

3. **Archive the app:**
   - Product → Archive
   - Wait for archive to complete

4. **Upload to App Store Connect:**
   - Window → Organizer
   - Select the archive
   - Click "Distribute App"
   - Follow the wizard

## 🔧 Configuration

### Environment Variables

Create a `Config.swift` file for environment-specific settings:

```swift
struct Config {
    static let apiBaseURL: String = {
        #if DEBUG
        return "http://localhost:8000"
        #else
        return "https://api.aphasiatherapy.com"
        #endif
    }()

    static let apiTimeout: TimeInterval = 30
    static let enableLogging: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
}
```

### App Configuration (Info.plist)

Key settings in `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

## 🎨 Customization

### Colors

Update colors in `Utilities/Extensions.swift`:

```swift
extension Color {
    static let primaryBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    static let primaryPurple = Color(red: 0.686, green: 0.322, blue: 0.871)
    // Add your custom colors
}
```

### App Icon

1. Prepare icons in required sizes (see AppIcon.appiconset)
2. Add images to `Assets.xcassets/AppIcon.appiconset/`
3. Update `Contents.json` with image references

Required sizes:
- iPhone: 40x40, 60x60, 80x80, 87x87, 120x120, 180x180
- iPad: 20x20, 29x29, 40x40, 58x58, 76x76, 80x80, 152x152, 167x167
- App Store: 1024x1024

### Localization

Add new languages in `Services/LocalizationManager.swift`:

```swift
enum Language: String, CaseIterable {
    case english = "en"
    case polish = "pl"
    case spanish = "es"  // New language

    var displayName: String {
        switch self {
        case .spanish: return "Español"
        // ...
        }
    }
}
```

Then add translations to the `translations` dictionary.

## 🧪 Testing

### Unit Tests

Run unit tests:
```bash
⌘ + U  # In Xcode
```

### UI Tests

Create UI tests in `AphasiaTherapyUITests/`:

```swift
func testLoginFlow() {
    let app = XCUIApplication()
    app.launch()

    // Test login flow
    let emailField = app.textFields["Email"]
    emailField.tap()
    emailField.typeText("test@example.com")

    // ... more test steps
}
```

### Manual Testing Checklist

- [ ] User registration
- [ ] User login
- [ ] Session browsing
- [ ] Exercise completion
- [ ] Progress tracking
- [ ] Profile updates
- [ ] Language switching
- [ ] iPad layout
- [ ] iPhone layout (various sizes)
- [ ] Network error handling
- [ ] Offline mode

## 📊 Performance Optimization

### Best Practices Implemented

1. **Lazy Loading**: Lists use `LazyVStack` and `LazyVGrid`
2. **Image Caching**: `AsyncImage` with built-in caching
3. **Async/Await**: Modern concurrency for network calls
4. **State Management**: Efficient use of `@State` and `@Published`
5. **Memory Management**: Proper use of `weak` and `unowned` references

### Monitoring

Use Xcode Instruments to profile:
- **Time Profiler**: CPU usage
- **Allocations**: Memory usage
- **Network**: API calls and data transfer
- **Energy Log**: Battery impact

## 🔒 Security

### Implemented Security Measures

1. **Keychain Storage**: Secure token storage
2. **HTTPS Only**: (Production) Encrypted data transmission
3. **Certificate Pinning**: (Recommended) Prevent MITM attacks
4. **Input Validation**: Sanitize user inputs
5. **Authentication**: JWT token-based auth
6. **Secure Code**: No hardcoded credentials

### Security Checklist

- [ ] Remove debug logs in production
- [ ] Enable App Transport Security
- [ ] Implement certificate pinning
- [ ] Add biometric authentication
- [ ] Encrypt sensitive local data
- [ ] Implement proper session timeout
- [ ] Add anti-screenshot for sensitive screens (optional)

## 📱 iPad Support

### Adaptive Layouts

The app uses `DeviceHelper` to detect device type and adjust layouts:

```swift
if DeviceHelper.isIPad {
    // iPad-specific layout with more columns
    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3))
} else {
    // iPhone layout with fewer columns
    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2))
}
```

### Navigation

- **iPhone**: Stack navigation with push/pop
- **iPad**: Split view navigation (can be enhanced)

## 🐛 Troubleshooting

### Common Issues

**Issue: Can't connect to backend**
- Solution: Check backend is running and URL is correct
- For physical device: Use computer's IP, not localhost
- Check firewall settings

**Issue: Build fails**
- Solution: Clean build folder (`⌘ + Shift + K`)
- Check Xcode and iOS SDK versions
- Verify code signing settings

**Issue: App crashes on launch**
- Solution: Check console logs in Xcode
- Verify Info.plist configuration
- Check for missing assets

**Issue: Localization not working**
- Solution: Verify language files are included in build
- Check `LocalizationManager` initialization
- Restart app after language change

## 📝 API Documentation

### Endpoints Used

**Authentication:**
- `POST /auth/login` - User login
- `POST /auth/register` - User registration

**User:**
- `GET /users/profile` - Get user profile
- `PUT /users/profile` - Update profile
- `GET /users/progress` - Get progress data

**Therapy:**
- `GET /therapy/sessions` - List sessions
- `GET /therapy/exercises/{id}` - Get session exercises
- `POST /therapy/sessions/{id}/progress` - Submit progress

### API Response Models

See `Models/` directory for complete data structures.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint for consistent formatting
- Write clear comments for complex logic
- Keep functions small and focused

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For issues and questions:
- **GitHub Issues**: Report bugs and feature requests
- **Email**: support@aphasiatherapy.com
- **Documentation**: See main README.md

## 🗺️ Roadmap

### Planned Features

- [ ] Offline mode with local storage
- [ ] Voice recording and playback
- [ ] Push notifications for reminders
- [ ] Apple Watch companion app
- [ ] Dark mode support
- [ ] HealthKit integration
- [ ] Family sharing features
- [ ] Clinician dashboard
- [ ] Custom exercise creation
- [ ] Social features (optional)

### Version History

**v1.0.0** (Current)
- Initial release
- Core therapy features
- iPhone and iPad support
- English and Polish languages
- Progress tracking

## 🙏 Acknowledgments

- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Backend powered by [FastAPI](https://fastapi.tiangolo.com/)
- Icons from [SF Symbols](https://developer.apple.com/sf-symbols/)

---

**Built with ❤️ for aphasia therapy**
