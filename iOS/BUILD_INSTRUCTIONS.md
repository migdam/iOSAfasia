# iOS App Build Instructions

Complete step-by-step guide to building the Aphasia Therapy iOS app.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Development Build](#development-build)
4. [Testing on Physical Device](#testing-on-physical-device)
5. [Production Build](#production-build)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

1. **macOS Ventura (13.0) or later**
   - This is required to run the latest version of Xcode

2. **Xcode 15.0 or later**
   - Download from Mac App Store
   - Or download from [Apple Developer](https://developer.apple.com/download/)

3. **Command Line Tools**
   ```bash
   xcode-select --install
   ```

4. **iOS Device** (optional, for device testing)
   - iPhone or iPad running iOS 16.0 or later

### Backend Setup

The iOS app requires the backend API to be running:

```bash
# Terminal 1: Start the backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m app.main
```

Backend will run on `http://localhost:8000`

## Initial Setup

### 1. Open the Project

```bash
cd iOS
open AphasiaTherapy.xcodeproj
```

Wait for Xcode to index the project.

### 2. Configure Backend URL

**For Simulator (localhost):**

No changes needed. Default configuration uses `http://localhost:8000`

**For Physical Device:**

1. Find your computer's IP address:
   ```bash
   ipconfig getifaddr en0  # WiFi
   # or
   ipconfig getifaddr en1  # Ethernet
   ```

2. Edit `iOS/AphasiaTherapy/Services/APIClient.swift`:
   ```swift
   init(baseURL: String = "http://192.168.x.x:8000") {
       self.baseURL = baseURL
       // ...
   }
   ```

3. Update `Info.plist` to allow HTTP to your IP:
   ```xml
   <key>NSExceptionDomains</key>
   <dict>
       <key>192.168.x.x</key>
       <dict>
           <key>NSExceptionAllowsInsecureHTTPLoads</key>
           <true/>
       </dict>
   </dict>
   ```

### 3. Select Build Target

In Xcode toolbar:
- Click on the device/simulator selector (next to Play/Stop buttons)
- Choose:
  - **For testing**: iPhone 15 simulator or your connected device
  - **For iPad**: iPad Pro simulator or connected iPad

## Development Build

### Building for Simulator

1. **Select Simulator:**
   - Xcode toolbar → Device selector → Choose iPhone/iPad simulator

2. **Build and Run:**
   - Press `⌘ + R` (Command + R)
   - Or click the Play button (▶️)

3. **Wait for Build:**
   - First build may take 2-5 minutes
   - Subsequent builds are faster (10-30 seconds)

4. **App Launches:**
   - Simulator will open automatically
   - App will launch on the simulator home screen

### Building for Physical Device

#### First Time Setup

1. **Connect Device:**
   - Connect iPhone/iPad via USB
   - Unlock device
   - Tap "Trust" when prompted

2. **Configure Signing:**
   - Select project in Navigator (left sidebar)
   - Select "AphasiaTherapy" target
   - Go to "Signing & Capabilities" tab
   - Check "Automatically manage signing"
   - Select your Team (Apple ID)

3. **Enable Developer Mode on Device:**
   - iOS 16+: Settings → Privacy & Security → Developer Mode → Enable
   - Restart device when prompted

4. **Build and Run:**
   - Select your device in toolbar
   - Press `⌘ + R`
   - Wait for "Running on [Device]" message

#### Troubleshooting Device Build

**Error: "Untrusted Developer"**
- On device: Settings → General → VPN & Device Management
- Tap your Apple ID
- Tap "Trust"

**Error: "Failed to code sign"**
- Check Apple ID is signed in: Xcode → Settings → Accounts
- Try: Xcode → Clean Build Folder (`⌘ + Shift + K`)
- Rebuild

## Production Build

### Prepare for Release

1. **Update Version Number:**
   - Select project → Target → General
   - Set Version: `1.0.0`
   - Set Build: `1`

2. **Set Release Configuration:**
   - Product → Scheme → Edit Scheme
   - Run → Build Configuration → Release

3. **Update API URL:**
   ```swift
   // APIClient.swift
   #if DEBUG
   let defaultURL = "http://localhost:8000"
   #else
   let defaultURL = "https://api.aphasiatherapy.com"
   #endif
   ```

4. **Enable Production Security:**
   - Remove all `NSExceptionAllowsInsecureHTTPLoads`
   - Ensure only HTTPS is allowed

### Create Archive

1. **Select "Any iOS Device":**
   - Toolbar → Device selector → Any iOS Device (arm64)

2. **Archive:**
   - Product → Archive
   - Wait for archive to complete (2-10 minutes)

3. **Organizer Opens:**
   - Shows your archive
   - Click "Distribute App"

### Distribution Options

#### TestFlight (Beta Testing)

1. **In Organizer:**
   - Click "Distribute App"
   - Select "TestFlight & App Store"
   - Click "Next"

2. **Upload:**
   - Select "Upload"
   - Click "Next"
   - Choose signing: Automatic
   - Click "Upload"

3. **Wait for Processing:**
   - Check App Store Connect
   - Processing takes 10-60 minutes
   - You'll receive email when ready

4. **Invite Testers:**
   - App Store Connect → TestFlight
   - Add internal/external testers
   - They'll receive invite via TestFlight app

#### App Store (Public Release)

1. **Create App in App Store Connect:**
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - My Apps → + → New App
   - Fill in app information

2. **Upload Build:**
   - Same as TestFlight process
   - Build appears in App Store Connect after processing

3. **Complete App Store Information:**
   - Screenshots (required for all device sizes)
   - Description
   - Keywords
   - Support URL
   - Privacy policy
   - Age rating

4. **Submit for Review:**
   - Click "Submit for Review"
   - Answer questionnaire
   - Review time: 1-3 days typically

## Building with Different Configurations

### Debug Build

```bash
xcodebuild -project AphasiaTherapy.xcodeproj \
           -scheme AphasiaTherapy \
           -configuration Debug \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           build
```

### Release Build

```bash
xcodebuild -project AphasiaTherapy.xcodeproj \
           -scheme AphasiaTherapy \
           -configuration Release \
           -destination 'generic/platform=iOS' \
           archive \
           -archivePath ./build/AphasiaTherapy.xcarchive
```

## Continuous Integration

### Using Xcode Cloud

1. **Enable Xcode Cloud:**
   - Product → Xcode Cloud → Create Workflow

2. **Configure Workflow:**
   - Choose branches to build
   - Set build triggers (on push, PR, etc.)
   - Configure test runs

### Using GitHub Actions

Create `.github/workflows/ios.yml`:

```yaml
name: iOS Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3

    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.0.app

    - name: Build
      run: |
        cd iOS
        xcodebuild -project AphasiaTherapy.xcodeproj \
                   -scheme AphasiaTherapy \
                   -destination 'platform=iOS Simulator,name=iPhone 15' \
                   build

    - name: Test
      run: |
        cd iOS
        xcodebuild -project AphasiaTherapy.xcodeproj \
                   -scheme AphasiaTherapy \
                   -destination 'platform=iOS Simulator,name=iPhone 15' \
                   test
```

## Troubleshooting

### Common Build Errors

#### Error: "Could not find module 'SwiftUI'"

**Solution:**
- Ensure deployment target is iOS 13.0+
- Check Project → Target → General → Deployment Info

#### Error: "Command PhaseScriptExecution failed"

**Solution:**
```bash
# Clean build folder
⌘ + Shift + K

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Rebuild
⌘ + B
```

#### Error: "No signing certificate found"

**Solution:**
- Xcode → Settings → Accounts
- Sign in with Apple ID
- Download manual profiles or enable automatic signing

### Runtime Errors

#### App Crashes on Launch

**Check:**
1. Console logs in Xcode (⌘ + Shift + C)
2. Crash logs: Window → Devices and Simulators → View Device Logs

**Common causes:**
- Missing Info.plist keys
- Invalid API URL
- Missing assets

#### Network Errors

**Check:**
1. Backend is running
2. Correct URL in APIClient.swift
3. Device and computer on same network (for physical device)
4. Info.plist allows HTTP (development only)

### Performance Issues

#### Slow Build Times

**Solutions:**
- Close other apps
- Disable indexing temporarily: Xcode → Settings → Locations → Derived Data → Delete
- Use incremental builds (default)
- Upgrade Mac hardware (RAM, SSD)

#### Slow Simulator

**Solutions:**
- Close unused simulators
- Choose simpler device (iPhone SE vs iPhone 15 Pro Max)
- Increase Mac RAM allocation to simulator
- Reset simulator: Device → Erase All Content and Settings

## Next Steps

After successful build:

1. **Test the app thoroughly** on different devices
2. **Profile performance** using Instruments
3. **Test network scenarios** (slow network, offline)
4. **Verify localization** works correctly
5. **Submit to TestFlight** for beta testing
6. **Gather feedback** and iterate

## Resources

- [Xcode Documentation](https://developer.apple.com/documentation/xcode)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [App Store Connect Guide](https://developer.apple.com/app-store-connect/)
- [TestFlight Documentation](https://developer.apple.com/testflight/)

## Support

If you encounter issues:

1. Check this troubleshooting guide
2. Search [Apple Developer Forums](https://developer.apple.com/forums/)
3. Check [Stack Overflow](https://stackoverflow.com/questions/tagged/ios)
4. Open an issue on GitHub

---

**Happy Building! 🚀**
