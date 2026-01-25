# DialedIn

A production-grade iOS fitness tracking application built with SwiftUI and VIPER architecture.

## Features

- **Real-time Workout Tracking**: Track exercises, sets, and reps with rest timers
- **iOS Live Activities**: Dynamic Island and Lock Screen workout sessions
- **Nutrition Logging**: Track meals and macros (calories, protein, carbs, fat)
- **HealthKit Integration**: Synchronize workout data with Apple Health
- **Training Programs**: Create and follow structured training programs with progress analytics
- **Multi-environment Configuration**: Dev/Mock/Prod environments for safe development
- **A/B Testing Framework**: Built-in framework for feature experimentation
- **Firebase Backend**: Cloud Firestore for data persistence and sync

## Architecture

- **VIPER Pattern**: Clean architecture with dependency injection
- **SwiftUI**: Modern declarative UI framework
- **Observation**: Reactive programming for data flow
- **Modular Design**: Testable, maintainable codebase

## Technologies

- Swift, SwiftUI, Observation
- HealthKit, ActivityKit
- Firebase (Firestore, Auth, Analytics, Crashlytics)
- Google Sign-In
- RevenueCat (In-App Purchases)
- Mixpanel (Analytics)
- Unit & UI Testing

## Setup Instructions

### Prerequisites

- Xcode 26.0 or later
- iOS 26.0+ deployment target
- Swift 6+

### Configuration

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd DialedIn
   ```

2. **Install dependencies**
   ```bash
   pod install
   ```

3. **Configure API Keys**
   - Copy `DialedIn/Utilities/Keys.swift.example` to `DialedIn/Utilities/Keys.swift`
   - Fill in your API keys:
     - OpenAI API key (if using AI features)
     - Mixpanel token
     - RevenueCat API key
   - **Note**: `Keys.swift` is gitignored for security. You must create it locally for the app to build.

4. **Configure Firebase**
   - Copy `DialedIn/GoogleServicePLists/GoogleService-Info-Example.plist` to:
     - `DialedIn/GoogleServicePLists/GoogleService-Info-Dev.plist` (for development)
     - `DialedIn/GoogleServicePLists/GoogleService-Info-Prod.plist` (for production)
   - Fill in your Firebase project credentials from the Firebase Console
   - **Note**: These files are gitignored for security. You must create them locally for the app to build.

5. **Configure Google Sign-In & URL schemes**
   - Copy `DialedIn/Info.plist.example` to `DialedIn/Info.plist`
   - Replace the placeholders with your values:
     - `YOUR_GOOGLE_CLIENT_ID_DEV` → Google Sign-In dev client ID (from Firebase Console)
     - `YOUR_GOOGLE_CLIENT_ID_PROD` → Google Sign-In prod client ID
     - `YOUR_DEEP_LINK_SCHEME` → Your app’s URL scheme (e.g. `dialedIn`)
   - **Note**: `Info.plist` is gitignored for security. You must create it locally for the app to build.

6. **Open the workspace**
   ```bash
   open DialedIn.xcworkspace
   ```

### Build Configurations

- **Debug**: Uses Dev Firebase configuration
- **Mock**: Uses mock services (no backend required)
- **Release**: Uses Prod Firebase configuration

## Project Structure

```
DialedIn/
├── Core/              # VIPER modules (Training, Nutrition, Profile, etc.)
├── Components/        # Reusable UI components
├── Services/          # Business logic services
├── Root/              # App entry point and dependency injection
├── Utilities/         # Helper utilities and constants
└── Resources/         # Prebuilt data (exercises, workouts)
```

## Testing

Run unit tests:
```bash
xcodebuild test -workspace DialedIn.xcworkspace -scheme DialedIn -destination 'platform=iOS Simulator,name=iPhone 15'
```

## License

Copyright (c) 2026 Andrew Coyle. All rights reserved.

This project is proprietary and confidential. Unauthorized copying, modification, distribution, or use of this project, via any medium, is strictly prohibited.

## Author

Andrew Coyle

