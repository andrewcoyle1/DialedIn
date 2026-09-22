# DialedIn

A production-grade iOS fitness tracking application built with SwiftUI and VIPER architecture.

## Features

- **Real-time Workout Tracking**: Track exercises, sets, and reps with rest timers
- **iOS Live Activities**: Dynamic Island and Lock Screen workout sessions
- **Nutrition Logging**: Track meals and macros (calories, protein, carbs, fat)
- **HealthKit Integration**: Synchronize workout data with Apple Health
- **Training Programs**: Create and follow structured training programs with progress analytics
- **Body Measurements & Steps**: Weight trends, 18 circumference sites, progress photos, daily steps
- **Recipes & Barcode Scanning**: Recipe builder plus Open Food Facts barcode lookup
- **AI Food Analysis**: Photo, description and nutrition-label analysis via Cloud Functions
- **Strava Integration**: OAuth connect and activity import
- **Gamification**: Streaks, progress and experience points
- **Multi-environment Configuration**: Dev/Mock/Prod environments for safe development
- **A/B Testing Framework**: Built-in framework for feature experimentation
- **Firebase Backend**: Cloud Firestore for persistence, Cloud Functions for AI, App Check for
  attestation

## Architecture

- **VIPER Pattern**: Each screen is an Interactor protocol, an `@Observable` Presenter, a SwiftUI
  View and a Router. `CoreInteractor` exposes every manager; screens depend on it through their
  own narrow protocol.
- **Dependency Injection**: `Dependencies(config:)` builds all managers for the selected build
  configuration and registers them in a `DependencyContainer`.
- **SwiftUI + Observation**: Declarative UI with reactive data flow.
- **Package-based infrastructure**: Auth, logging, purchasing, routing, data sync and gamification
  come from the `Swiftful*` Swift packages, surfaced through `*+Alias.swift` typealiases.

See [CLAUDE.md](CLAUDE.md) for the full architecture reference.

## Technologies

- Swift 6, SwiftUI, Observation
- HealthKit, ActivityKit, SwiftData
- Firebase (Firestore, Auth, Analytics, Crashlytics, App Check, Cloud Functions)
- Genkit + Vertex AI (server-side AI)
- Google Sign-In, Sign in with Apple
- RevenueCat (In-App Purchases) / StoreKit
- Mixpanel (Analytics)
- Open Food Facts, Strava
- Swift Package Manager
- Unit & UI Testing, SwiftLint

## Setup Instructions

### Prerequisites

- Xcode 26.0 or later
- iOS 26.0+ deployment target
- Swift 6 language mode (test and extension targets still build in Swift 5 mode)
- SwiftLint, for `swiftlint` to run locally

### Configuration

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd DialedIn
   ```

2. **Install dependencies**

   Dependencies are managed with Swift Package Manager — there is nothing to install by hand.
   Xcode resolves them when you open the project.

3. **Configure API Keys**
   - Copy `DialedIn/Utilities/Keys.swift.example` to `DialedIn/Utilities/Keys.swift`
   - Fill in the 33 constants:
     - OpenAI API key (if using AI features)
     - Mixpanel token
     - RevenueCat API key
     - Strava client ID and secret
     - 28 `*ManagerKey` strings — arbitrary names used as local-persistence paths. Keep them
       stable once chosen; renaming one orphans data already stored under the old name.
   - **Note**: `Keys.swift` is gitignored. You must create it locally for the app to build.

4. **Configure Firebase**
   - Copy `DialedIn/SupportingFiles/GoogleServicePLists/GoogleService-Info-Example.plist` to,
     in the same folder:
     - `GoogleService-Info-Dev.plist` (for development)
     - `GoogleService-Info-Prod.plist` (for production)
   - Fill in your Firebase project credentials from the Firebase Console
   - **Note**: These files are gitignored for security. You must create them locally for the app to build.

5. **Configure Google Sign-In & URL schemes**
   - Copy `DialedIn/Info.plist.example` to `DialedIn/Info.plist`
   - The example already carries the `REVERSED_CLIENT_ID` for both Firebase projects and the
     `compound` deep-link scheme, so for this project it is a straight copy. If you point the app
     at your own Firebase projects, replace each reversed client ID with the one from your
     `GoogleService-Info` plists.
   - **Note**: `Info.plist` is gitignored. Google Sign-In fails at runtime without it.

6. **Open the project**
   ```bash
   open DialedIn.xcodeproj
   ```
   Then pick a scheme: `DialedIn - Development`, `DialedIn - Mock` (no backend required), or
   `DialedIn - Production`. There is no scheme called plain `DialedIn`.

### Build Configurations

| Scheme | Configuration | Backend |
|---|---|---|
| `DialedIn - Development` | Debug | Firebase dev project |
| `DialedIn - Mock` | Mock | Mock services only, no Firebase |
| `DialedIn - Production` | Release | Firebase prod project |

## Project Structure

```
DialedIn/
├── Core/                     # VIPER modules (Training, Nutrition, Profile, Onboarding, ...)
├── Components/               # Reusable UI components
├── Managers/                 # Domain managers resolved through CoreInteractor
├── Root/                     # App entry point, DI container, CoreInteractor/CoreRouter
├── Extensions/               # Swift/SwiftUI extensions
├── Utilities/                # Helpers, constants, Keys.swift
└── SupportingFiles/          # GoogleService plists, prebuilt exercise/workout JSON

WorkoutSessionActivity/       # Live Activity / Dynamic Island widget extension
Shared/                       # Code shared between the app and the widget extension
functions/                    # Firebase Cloud Functions (Node, Genkit/Vertex AI)
DialedInUnitTests/            # Unit tests
DialedInUITests/              # UI tests
```

## Testing

Run tests:
```bash
xcodebuild test -project DialedIn.xcodeproj -scheme 'DialedIn - Development' \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

The suite is 2,715 tests across 168 files in `DialedInUnitTests/`, and it passes. Run the whole
thing only when pushing — `-only-testing:DialedInUnitTests/<Suite>` is about forty-five seconds
against fifteen minutes for everything. Add `-skip-testing:DialedInUITests` to anything routine:
the UI bundle is three tests, one of them chronically flaky, and a single flake there prints
`** TEST FAILED **` over a clean unit run. See CLAUDE.md for the full cadence.

Lint (SwiftLint must be installed):
```bash
swiftlint
```

## License

Copyright (c) 2026 Andrew Coyle. All rights reserved.

This project is proprietary and confidential. Unauthorized copying, modification, distribution, or use of this project, via any medium, is strictly prohibited.

## Author

Andrew Coyle

