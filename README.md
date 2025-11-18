# 🧠 Aphasia Speech Therapy - iOS Application

<div align="center">

  ![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)
  ![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
  ![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green.svg)
  ![Platform](https://img.shields.io/badge/Platform-iPhone%20%7C%20iPad-lightgrey.svg)
  ![License](https://img.shields.io/badge/License-MIT-blue.svg)

  **A comprehensive speech therapy application for individuals with aphasia**

  *Supporting recovery through interactive exercises and progress tracking*

  [Features](#features) • [Quick Start](#quick-start) • [Documentation](#documentation) • [Screenshots](#screenshots)

</div>

---

## 📖 Overview

This repository contains a production-ready iOS application designed to help individuals with aphasia improve their communication skills through structured therapy sessions. The app provides an intuitive interface for both patients and clinicians, with comprehensive progress tracking and multi-language support.

### What is Aphasia?

Aphasia is a language disorder that affects a person's ability to communicate. It can impact speaking, understanding, reading, and writing. This app provides therapeutic exercises designed by speech-language pathologists to support recovery.

## ✨ Features

### 🎯 Core Functionality

- **Interactive Therapy Sessions**
  - Word naming exercises
  - Sentence completion tasks
  - Comprehension challenges
  - Repetition practice
  - Reading exercises
  - Writing tasks

- **Progress Tracking**
  - Detailed analytics and charts
  - Session history
  - Performance by exercise type
  - Streak tracking
  - Time spent metrics

- **Multi-Language Support**
  - 🇬🇧 English
  - 🇵🇱 Polish (Polski)
  - Easy language switching
  - Localized content and exercises

- **Universal App**
  - Optimized for iPhone (all sizes)
  - Optimized for iPad
  - Adaptive layouts
  - Landscape and portrait support

### 🔐 Security & Privacy

- Secure authentication with JWT tokens
- Keychain storage for sensitive data
- HTTPS encryption (production)
- No data sharing with third parties
- HIPAA compliance considerations

### ♿ Accessibility

- Voice-over support
- Large text options
- High contrast mode ready
- Haptic feedback
- Simple, clear interface

## 🚀 Quick Start

### For Users

#### Download from App Store (Coming Soon)

Search for "Aphasia Therapy" in the App Store or visit [link to be added].

#### Requirements

- iPhone or iPad running iOS 16.0 or later
- Internet connection for initial setup
- 50 MB of free storage

### For Developers

#### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Apple Developer account (for device testing)
- Basic knowledge of Swift and SwiftUI

#### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/iOSAfasia.git
   cd iOSAfasia
   ```

2. **Open the iOS project:**
   ```bash
   cd iOS
   open AphasiaTherapy.xcodeproj
   ```

3. **Configure the backend URL:**
   - For simulator: Uses `localhost:8000` by default
   - For device: Update `Services/APIClient.swift` with your computer's IP

4. **Build and run:**
   - Select your target device (simulator or physical device)
   - Press `⌘ + R` or click the Run button

#### Backend Setup

The app requires a FastAPI backend (not included in this repo). You'll need:

- Python 3.8+
- FastAPI backend running on `http://localhost:8000`
- See backend documentation for setup instructions

## 📱 Screenshots

### iPhone

<div style="display: flex; gap: 10px;">
  <img src="docs/screenshots/iphone-home.png" width="200" alt="Home Screen">
  <img src="docs/screenshots/iphone-sessions.png" width="200" alt="Sessions">
  <img src="docs/screenshots/iphone-exercise.png" width="200" alt="Exercise">
  <img src="docs/screenshots/iphone-progress.png" width="200" alt="Progress">
</div>

### iPad

<div style="display: flex; gap: 10px;">
  <img src="docs/screenshots/ipad-home.png" width="400" alt="iPad Home">
  <img src="docs/screenshots/ipad-exercise.png" width="400" alt="iPad Exercise">
</div>

*Screenshots to be added after UI design finalization*

## 📚 Documentation

### User Documentation

- **[User Guide](docs/USER_GUIDE.md)** - Complete guide for app users
- **[Exercise Types](docs/EXERCISE_TYPES.md)** - Detailed description of exercises
- **[FAQ](docs/FAQ.md)** - Frequently asked questions

### Developer Documentation

- **[iOS README](iOS/README.md)** - Detailed iOS app documentation
- **[Build Instructions](iOS/BUILD_INSTRUCTIONS.md)** - Step-by-step build guide
- **[API Documentation](docs/API.md)** - Backend API reference
- **[Architecture](docs/ARCHITECTURE.md)** - Technical architecture overview
- **[Contributing Guide](CONTRIBUTING.md)** - How to contribute

## 🏗️ Project Structure

```
iOSAfasia/
├── iOS/                          # iOS application
│   ├── AphasiaTherapy/          # Main app directory
│   │   ├── Models/              # Data models
│   │   ├── Views/               # SwiftUI views
│   │   ├── ViewModels/          # View models
│   │   ├── Services/            # Business logic
│   │   ├── Utilities/           # Helper utilities
│   │   ├── Resources/           # Assets and resources
│   │   └── Localization/        # Translation files
│   ├── AphasiaTherapy.xcodeproj # Xcode project
│   ├── README.md                # iOS documentation
│   └── BUILD_INSTRUCTIONS.md    # Build guide
├── docs/                         # Documentation
├── README.md                     # This file
└── LICENSE                       # MIT License
```

## 🛠️ Technology Stack

### iOS App

- **Language**: Swift 5.0
- **UI Framework**: SwiftUI 3.0
- **Minimum iOS**: 16.0
- **Architecture**: MVVM (Model-View-ViewModel)
- **Networking**: URLSession with async/await
- **Storage**: Keychain, UserDefaults
- **Dependency Management**: Swift Package Manager (future)

### Backend (Separate Repository)

- **Framework**: FastAPI (Python)
- **Database**: SQLite / PostgreSQL
- **Authentication**: JWT tokens
- **API**: RESTful

## 🧪 Testing

### Automated Tests

Run tests in Xcode:
```bash
⌘ + U  # Run all tests
```

### Manual Testing

- [ ] User authentication flow
- [ ] Exercise completion
- [ ] Progress tracking
- [ ] Language switching
- [ ] iPad layout
- [ ] Network error handling
- [ ] Offline functionality

## 🚢 Deployment

### TestFlight (Beta)

1. Archive the app in Xcode
2. Upload to App Store Connect
3. Add beta testers
4. Distribute via TestFlight

### App Store

1. Complete app information in App Store Connect
2. Submit for review
3. Typical review time: 1-3 days

See [BUILD_INSTRUCTIONS.md](iOS/BUILD_INSTRUCTIONS.md) for detailed steps.

## 🗺️ Roadmap

### Version 1.0 (Current)
- ✅ Core therapy exercises
- ✅ Progress tracking
- ✅ Multi-language support (English, Polish)
- ✅ iPhone and iPad support
- ✅ User authentication

### Version 1.1 (Planned)
- [ ] Offline mode with local storage
- [ ] Voice recording and playback
- [ ] Push notifications for reminders
- [ ] Dark mode support
- [ ] Additional languages (Spanish, French)

### Version 2.0 (Future)
- [ ] Apple Watch companion app
- [ ] HealthKit integration
- [ ] Family sharing features
- [ ] Clinician dashboard
- [ ] Custom exercise creation
- [ ] Video exercises
- [ ] Speech-to-text integration

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code of Conduct

We are committed to providing a welcoming and inclusive experience. Please read our [Code of Conduct](CODE_OF_CONDUCT.md).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Project Lead**: [Your Name]
- **iOS Development**: [Developer Names]
- **Backend Development**: [Developer Names]
- **Clinical Advisor**: [SLP Names]
- **UI/UX Design**: [Designer Names]

## 🙏 Acknowledgments

- Speech-language pathologists who provided clinical guidance
- Beta testers for valuable feedback
- Open source community for excellent tools and libraries
- Aphasia community for inspiration and support

## 📞 Support

### For Users

- **Email**: support@aphasiatherapy.com
- **Website**: [www.aphasiatherapy.com](https://www.aphasiatherapy.com)
- **FAQ**: [docs/FAQ.md](docs/FAQ.md)

### For Developers

- **GitHub Issues**: Report bugs and request features
- **Discussions**: Technical discussions and questions
- **Wiki**: Additional technical documentation

## 🔗 Links

- **App Store**: [Coming Soon]
- **Website**: [Coming Soon]
- **Backend Repository**: [Link to backend repo]
- **Documentation**: [https://docs.aphasiatherapy.com](https://docs.aphasiatherapy.com)

## 📊 Statistics

- **Lines of Code**: ~5,000
- **Number of Views**: 15+
- **Supported Languages**: 2
- **Exercise Types**: 6
- **Minimum iOS Version**: 16.0

## 🌟 Star History

If you find this project helpful, please consider giving it a star on GitHub!

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/iOSAfasia&type=Date)](https://star-history.com/#yourusername/iOSAfasia&Date)

---

<div align="center">

  **Made with ❤️ for the aphasia community**

  [Report Bug](https://github.com/yourusername/iOSAfasia/issues) • [Request Feature](https://github.com/yourusername/iOSAfasia/issues) • [Documentation](docs/)

</div>
