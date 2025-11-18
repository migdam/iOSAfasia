# Deployment Guide - Aphasia Therapy iOS App

Complete guide for deploying the Aphasia Therapy iOS app to the App Store.

## Table of Contents

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [App Store Connect Setup](#app-store-connect-setup)
3. [Building for Production](#building-for-production)
4. [TestFlight Beta Testing](#testflight-beta-testing)
5. [App Store Submission](#app-store-submission)
6. [Post-Submission](#post-submission)
7. [Maintenance and Updates](#maintenance-and-updates)

## Pre-Deployment Checklist

### Legal and Business

- [ ] **Apple Developer Account**
  - Enrolled in Apple Developer Program ($99/year)
  - Account in good standing

- [ ] **App Name**
  - Unique app name chosen
  - Trademark search completed (if applicable)
  - Name available in App Store Connect

- [ ] **Legal Documents**
  - Privacy Policy created and hosted
  - Terms of Service created and hosted
  - EULA (End User License Agreement) if needed

- [ ] **Compliance**
  - HIPAA compliance review (if handling health data)
  - COPPA compliance (if targeting children)
  - GDPR compliance (if available in EU)

### Technical Requirements

- [ ] **App Configuration**
  - Unique Bundle Identifier set
  - App version number decided (e.g., 1.0.0)
  - Build number set (start with 1)

- [ ] **Code Quality**
  - All compiler warnings resolved
  - No debug code or print statements in production
  - Removed all test credentials
  - API keys properly secured

- [ ] **Testing**
  - Tested on multiple iPhone models
  - Tested on multiple iPad models
  - Tested on different iOS versions (16.0+)
  - All features working correctly
  - No crashes or major bugs

- [ ] **Performance**
  - App launches in under 3 seconds
  - Smooth scrolling and animations
  - No memory leaks
  - Battery usage optimized

- [ ] **Assets**
  - App Icon in all required sizes
  - Launch screen configured
  - All images optimized
  - Missing image checks completed

- [ ] **Content**
  - All text finalized
  - Translations complete and reviewed
  - Exercise content verified by SLP

## App Store Connect Setup

### 1. Create App Record

1. **Log in to App Store Connect**
   - Visit [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - Sign in with Apple Developer account

2. **Create New App**
   - Click "My Apps"
   - Click "+" button → "New App"
   - Fill in:
     - Platform: iOS
     - Name: Aphasia Speech Therapy
     - Primary Language: English
     - Bundle ID: com.aphasiatherapy.app
     - SKU: APHASIA_THERAPY_001
     - User Access: Full Access

### 2. App Information

#### General Information

```
App Name: Aphasia Speech Therapy
Subtitle: Speech & Language Recovery
Category:
  Primary: Medical
  Secondary: Education

Content Rights:
☑ Contains third-party content
☑ You have the rights to use all content

Age Rating:
  4+ (Medical/Treatment Information)
```

#### Pricing and Availability

```
Price: Free (or set price)
Availability: All countries (or select specific)
Pre-order: No
App Store Distribution: Available to everyone
```

### 3. Prepare Screenshots

Required sizes for all device types:

#### iPhone 6.7" (iPhone 15 Pro Max)
- 1290 x 2796 pixels (portrait)
- Minimum 1 screenshot, maximum 10

#### iPhone 6.5" (iPhone 15 Plus)
- 1284 x 2778 pixels (portrait)
- Can use 6.7" screenshots if similar

#### iPhone 5.5" (iPhone 8 Plus)
- 1242 x 2208 pixels (portrait)
- Required if supporting iOS 16

#### iPad Pro 12.9" (3rd gen)
- 2048 x 2732 pixels (portrait)
- Minimum 1 screenshot, maximum 10

#### iPad Pro 12.9" (2nd gen)
- 2048 x 2732 pixels (portrait)
- Can use 3rd gen screenshots

**Screenshot Checklist:**
- [ ] Home screen
- [ ] Therapy sessions list
- [ ] Exercise in progress
- [ ] Progress tracking
- [ ] Profile/settings
- All text visible and readable
- No personal information visible
- Representative of actual app

### 4. App Description

#### Description Template

```
Transform your aphasia therapy with our comprehensive mobile app designed for speech and language recovery.

FEATURES:

🗣 INTERACTIVE EXERCISES
• Word naming tasks
• Sentence completion
• Comprehension challenges
• Repetition practice
• Reading exercises
• Writing tasks

📊 PROGRESS TRACKING
• Detailed performance analytics
• Session history and trends
• Personalized insights
• Achievement tracking

🌍 MULTI-LANGUAGE SUPPORT
• English
• Polish (Polski)
• More languages coming soon

📱 DESIGNED FOR YOU
• Works on iPhone and iPad
• Beautiful, accessible interface
• Easy to use for all ages
• Practice anywhere, anytime

DEVELOPED WITH EXPERTS
Created in collaboration with certified speech-language pathologists to ensure evidence-based therapeutic content.

PRIVACY FIRST
Your therapy data is private and secure. We never share your information with third parties.

SUPPORT
Questions? Contact us at support@aphasiatherapy.com

Perfect for:
• Individuals with aphasia
• Caregivers and family members
• Speech-language pathologists
• Healthcare facilities

Start your recovery journey today!
```

#### Keywords (100 character limit)

```
aphasia,speech therapy,language,stroke recovery,brain injury,SLP,communication,rehabilitation
```

#### Support URL

```
https://aphasiatherapy.com/support
```

#### Marketing URL (optional)

```
https://aphasiatherapy.com
```

### 5. Additional Information

#### Copyright

```
2024 Aphasia Therapy Inc. All rights reserved.
```

#### Trade Representative Contact (if applicable)

Required for South Korea distribution.

#### Review Notes (Important!)

```
For App Review Team:

TEST ACCOUNT:
Email: review@aphasiatherapy.com
Password: TestReview123!

TESTING INSTRUCTIONS:
1. Log in with the provided credentials
2. From home screen, select any therapy session
3. Complete 2-3 exercises to see the flow
4. View progress in the Progress tab
5. Check profile settings in Profile tab

NOTES:
- Backend server is live and stable
- All exercise content has been reviewed by licensed SLPs
- Privacy policy and terms are available in-app and on our website
- The app requires internet connection for initial login and syncing

Please contact us at review-support@aphasiatherapy.com if you have any questions.
```

#### Attachment (if needed)

Include video demo if app has complex features.

## Building for Production

### 1. Pre-Build Configuration

#### Update Build Settings

```swift
// In project settings
Version: 1.0.0
Build: 1

// In APIClient.swift
#if DEBUG
let baseURL = "http://localhost:8000"
#else
let baseURL = "https://api.aphasiatherapy.com"
#endif
```

#### Update Info.plist

Remove development-only settings:

```xml
<!-- Remove or comment out -->
<!-- <key>NSAllowsArbitraryLoads</key> -->
```

Ensure required keys are present:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

### 2. Code Signing

1. **In Xcode:**
   - Select project → Target → Signing & Capabilities
   - Team: Select your team
   - Signing Certificate: "Apple Distribution"
   - Provisioning Profile: Automatic or manual

2. **Verify:**
   - Bundle Identifier matches App Store Connect
   - Signing identity is valid
   - Provisioning profile is not expired

### 3. Create Archive

1. **Select Build Target:**
   - Product → Destination → Any iOS Device (arm64)

2. **Set to Release:**
   - Product → Scheme → Edit Scheme
   - Run → Build Configuration → Release
   - Click "Close"

3. **Clean Build:**
   - Product → Clean Build Folder (⌘ + Shift + K)

4. **Archive:**
   - Product → Archive
   - Wait for build (5-15 minutes)
   - Organizer window opens when complete

### 4. Validate Archive

In Organizer:

1. Select your archive
2. Click "Validate App"
3. Choose distribution options:
   - App Store Connect
   - Automatic signing
4. Click "Validate"
5. Wait for validation (2-5 minutes)
6. Fix any errors that appear

Common validation issues:
- Missing icons
- Invalid provisioning
- Code signing errors
- Missing entitlements

### 5. Upload to App Store Connect

1. **In Organizer:**
   - Click "Distribute App"
   - Select "App Store Connect"
   - Click "Next"

2. **Distribution Options:**
   - Select "Upload"
   - Click "Next"

3. **Signing Options:**
   - Choose "Automatically manage signing"
   - Click "Next"

4. **Review:**
   - Review app information
   - Click "Upload"

5. **Wait:**
   - Upload takes 5-20 minutes depending on connection
   - You'll see progress bar
   - "Upload Successful" message appears when done

6. **Processing:**
   - Build appears in App Store Connect within 10-30 minutes
   - You'll receive email when processing is complete
   - Processing can take up to 2 hours

## TestFlight Beta Testing

### 1. Internal Testing

**Set Up Internal Testing:**

1. App Store Connect → TestFlight → Internal Testing
2. Click "+" to create new group
3. Name: "Internal Team"
4. Add testers (must have developer account access)
5. Select build to test
6. Enable automatic distribution

**Internal Testers:**
- Up to 100 testers
- No review required
- Instant access
- Can have 90 builds at once

### 2. External Testing

**Set Up External Testing:**

1. App Store Connect → TestFlight → External Testing
2. Click "+" to create new group
3. Name: "Public Beta"
4. Add test information:
   - What to test
   - Feedback email
   - Test duration

**Submit for Beta App Review:**

1. Add beta app information:
   - Contact information
   - Notes for reviewer
   - Export compliance info
   - Test account credentials

2. Submit for review
   - Review takes 24-48 hours
   - You'll receive email notification

3. Add external testers:
   - Email addresses or public link
   - Up to 10,000 testers
   - Invite sent via email

**Beta Testing Checklist:**
- [ ] Internal testing completed (1-2 weeks)
- [ ] All major bugs fixed
- [ ] External beta submitted
- [ ] Beta feedback collected
- [ ] Beta issues resolved
- [ ] Ready for public release

## App Store Submission

### 1. Prepare App Store Information

In App Store Connect → My Apps → Your App:

#### Version Information

```
Version Number: 1.0.0
Copyright: 2024 Aphasia Therapy Inc.
Trade Representative Contact Information: [if applicable]
```

#### What's New in This Version

```
Welcome to Aphasia Speech Therapy!

This is our initial release featuring:

✨ Six types of therapeutic exercises designed by speech-language pathologists
📊 Comprehensive progress tracking with detailed analytics
🌍 Support for English and Polish languages
📱 Beautiful interface optimized for iPhone and iPad
🔒 Secure, private, and HIPAA-compliant

We're excited to support your recovery journey!

Have feedback? Email us at support@aphasiatherapy.com
```

#### Promotional Text (Optional, 170 characters)

```
Evidence-based speech therapy exercises designed by certified SLPs. Track your progress and practice anywhere with our easy-to-use app.
```

### 2. App Review Information

#### Sign-In Information

```
Username: review@aphasiatherapy.com
Password: TestReview123!

Sign-in required: Yes
Sign-in note: Test account provided above. Please use this account for review.
```

#### Contact Information

```
First Name: [Your First Name]
Last Name: [Your Last Name]
Phone Number: [Your Phone]
Email: review-support@aphasiatherapy.com

Notes:
Available 9 AM - 5 PM EST for any questions during review.
```

#### Demo Account Information

Provide detailed credentials and instructions.

### 3. Age Rating Questionnaire

Answer all questions accurately:

```
Medical/Treatment Information: None or Infrequent
Unrestricted Web Access: No
Gambling: No
Violence: None
Horror/Fear: None
Sexual Content: None
Profanity: None
Alcohol, Tobacco, Drugs: None

Result: 4+
```

### 4. Submit for Review

1. **Final Check:**
   - All required fields completed
   - Screenshots uploaded
   - Description finalized
   - Build selected
   - Pricing set

2. **Submit:**
   - Click "Save"
   - Click "Add for Review"
   - Review summary
   - Click "Submit for Review"

3. **Status Changes:**
   - Waiting for Review (1-3 days typically)
   - In Review (1-2 days)
   - Pending Developer Release (approved!)
   - Ready for Sale

## Post-Submission

### Review Process Timeline

| Status | Duration | Action |
|--------|----------|--------|
| Waiting for Review | 1-3 days | Monitor email |
| In Review | 1-2 days | Be available for questions |
| Pending Developer Release | N/A | Release when ready |
| Ready for Sale | Immediate | App is live! |

### If Rejected

**Common Rejection Reasons:**

1. **Crashes or bugs**
   - Fix issues
   - Upload new build
   - Resubmit

2. **Incomplete information**
   - Update app information
   - Resubmit (no new build needed)

3. **Guideline violations**
   - Address concerns
   - Respond to reviewer
   - May need code changes

4. **Performance issues**
   - Optimize code
   - Upload new build
   - Resubmit

**Response Process:**

1. Read rejection reason carefully
2. Fix all mentioned issues
3. Respond in Resolution Center
4. Upload new build if needed
5. Resubmit for review

### Release

**Manual Release:**

1. App Store Connect → My Apps
2. Select your app
3. Version in "Pending Developer Release"
4. Click "Release This Version"
5. App goes live in 2-24 hours

**Automatic Release:**

Set in app version information before submission.

### Post-Release

**Immediate Actions:**

- [ ] Verify app appears in App Store
- [ ] Test download and installation
- [ ] Download on multiple devices
- [ ] Check all features work
- [ ] Monitor crash reports
- [ ] Watch reviews and ratings

**Monitoring:**

- App Store Connect → Analytics
- TestFlight → Crashes
- App Store → Reviews

## Maintenance and Updates

### Planning Updates

**Version Numbering:**

- Major updates: 2.0.0
- Minor updates: 1.1.0
- Bug fixes: 1.0.1

**Update Frequency:**

- Bug fixes: As needed
- Minor updates: Monthly
- Major updates: Quarterly

### Submitting Updates

1. Fix bugs or add features
2. Increment version number
3. Update "What's New"
4. Create new archive
5. Upload to App Store Connect
6. Submit new version for review

### Responding to Reviews

**Best Practices:**

- Respond within 24-48 hours
- Be professional and empathetic
- Thank users for feedback
- Explain fixes or workarounds
- Invite continued feedback

**Example Response:**

```
Thank you for your feedback! We're sorry you experienced [issue].
We've released an update that fixes this problem. Please update
to version 1.0.1 and let us know if you continue to have issues.

Feel free to contact us at support@aphasiatherapy.com for
personalized assistance.

- The Aphasia Therapy Team
```

### Analytics and Metrics

**Key Metrics to Track:**

- Downloads per day/week/month
- Active users
- Session duration
- Exercise completion rate
- User retention
- Crash rate
- Ratings and reviews

**Tools:**

- App Store Connect Analytics
- Firebase Analytics (if implemented)
- TestFlight feedback
- User support emails

## Troubleshooting

### Archive Issues

**"No valid iOS distribution certificate found"**
- Check developer account status
- Renew certificates in developer portal
- Download and install in Xcode

**"Provisioning profile doesn't match"**
- Update bundle identifier
- Recreate provisioning profile
- Try automatic signing

### Upload Issues

**"Invalid binary"**
- Ensure all required architectures included
- Check for unsupported APIs
- Verify minimum deployment target

**"Missing required icon"**
- Add all required icon sizes
- Check icon file format (PNG)
- Verify icon naming

### Review Issues

**App takes too long to review**
- Normal: 1-7 days
- If longer: Contact App Review
- Expedite available for urgent issues

**App stuck "In Review"**
- Usually resolves within 48 hours
- Contact App Review if > 5 days
- Provide tracking number

## Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [TestFlight Guide](https://developer.apple.com/testflight/)

## Support

Questions about deployment?

- **Email**: dev-support@aphasiatherapy.com
- **Slack**: #deployment channel
- **Documentation**: This guide!

---

**Good luck with your App Store submission! 🚀**
