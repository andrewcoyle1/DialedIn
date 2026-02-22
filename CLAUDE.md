# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development

**Package manager**: CocoaPods. Open `DialedIn.xcworkspace` (not `.xcodeproj`) after running:
```bash
pod install
```

**Build via Xcode**: Select the `DialedIn` scheme and target device, then build with ⌘B or run with ⌘R.

**Run tests**:
```bash
xcodebuild test -workspace DialedIn.xcworkspace -scheme DialedIn -destination 'platform=iOS Simulator,name=iPhone 16'
```

**Lint** (SwiftLint must be installed):
```bash
swiftlint
```

SwiftLint config (`.swiftlint.yml`): line limit 300, type body 500 lines, file length 750 lines, `trailing_whitespace` disabled.

## First-Time Setup

Copy example files and fill in credentials:
- `DialedIn/Utilities/Keys.swift.example` → `DialedIn/Utilities/Keys.swift` (OpenAI, Mixpanel, RevenueCat keys)
- `DialedIn/SupportingFiles/Info.plist.example` → `DialedIn/Info.plist` (URL schemes for Google Sign-In)
- `DialedIn/GoogleServicePLists/GoogleService-Info-Example.plist` → `GoogleService-Info-Dev.plist` and `GoogleService-Info-Prod.plist`

## Architecture

The app uses a **custom VIPER-like pattern** where `CoreInteractor` is a single global struct that exposes all managers, and each screen defines its own interactor protocol as an extension on `CoreInteractor`.

### The Four Components Per Screen

**1. Interactor (protocol + CoreInteractor extension)**
Defines the data/operations a screen needs. Never instantiated separately — the screen just receives a `CoreInteractor` typed as its specific protocol:
```swift
@MainActor
protocol BodyMetricsInteractor: GlobalInteractor {
    var measurementHistory: [BodyMeasurementEntry] { get }
    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry]
}

extension CoreInteractor: BodyMetricsInteractor { }
```

**2. Presenter (`@Observable @MainActor class`)**
Holds the interactor and router. Transforms data for the view. All user actions and lifecycle events are methods here:
```swift
@Observable
@MainActor
class BodyMetricsPresenter {
    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    func onViewAppear() { interactor.trackScreenEvent(event: Event.onAppear) }
    func onSomethingPressed() { router.showSomeView(...) }
}
```
Events are defined as a nested `enum Event: LoggableEvent` on the presenter.

**3. View (SwiftUI View)**
Holds the presenter as `@State`. Calls presenter methods for all interactions:
```swift
struct BodyMetricsView: View {
    @State var presenter: BodyMetricsPresenter

    var body: some View {
        // reads presenter properties, calls presenter methods on actions
    }
}
```

**4. Router (protocol extending `GlobalRouter`)**
Declares navigation methods. The actual implementation uses `SwiftfulRouting`'s `AnyRouter`. `GlobalRouter` provides `dismissScreen()`, `showAlert(...)`, `showLoadingModal()`, etc. for free.

### Dependency Flow

```
DialedInApp
  └── Dependencies(config:)        ← creates all managers based on BuildConfiguration
        └── DependencyContainer    ← service locator, registered by type
              └── CoreInteractor   ← resolves all managers from container
                    └── CoreBuilder / screen builders
```

**Build configurations** (`BuildConfiguration` enum):
- `.mock(isSignedIn:)` — all mock services, no Firebase. Used for unit tests and previews.
- `.dev` — Firebase dev project, `LocalABTestService`, RevenueCat
- `.prod` — Firebase prod project, `FirebaseABTestService`, StoreKit

### SwiftUI Previews

Use `DevPreview.shared` to get a pre-configured mock container:
```swift
#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let presenter = SomePresenter(interactor: interactor, router: MockRouter())
    return SomeView(presenter: presenter)
}
```

### GlobalInteractor

`GlobalInteractor` protocol provides every interactor with:
- `trackEvent(event:)` / `trackScreenEvent(event:)` — analytics
- `playHaptic(option:)` — haptics

All event tracking uses types conforming to `LoggableEvent` (eventName, parameters, LogType).

## Key Managers

All managers live in `DialedIn/Managers/` and are accessed through `CoreInteractor`:

| Manager | Purpose |
|---|---|
| `AuthManager` | Firebase auth (Apple, Google, anonymous) |
| `UserManager` | Firestore user profile |
| `WorkoutSessionManager` | Logging and syncing workout sessions |
| `WorkoutTemplateManager` | Workout template CRUD |
| `ExerciseTemplateManager` | Exercise library (local SwiftData + Firestore) |
| `TrainingProgramManager` | Training programs with local/remote sync |
| `NutritionManager` / `MealLogManager` | Food logging and nutrition targets |
| `IngredientTemplateManager` / `RecipeTemplateManager` | Food library |
| `BodyMeasurementsManager` | Body measurements and scale weight |
| `HealthKitManager` / `HKWorkoutManager` | HealthKit read/write |
| `LiveActivityManager` | Dynamic Island / Lock Screen workout tracking |
| `PurchaseManager` | RevenueCat (dev) / StoreKit (prod) |
| `LogManager` | Multi-service analytics (Console, Firebase, Mixpanel, Crashlytics) |
| `ABTestManager` | A/B tests via Firebase Remote Config (prod) or local (dev) |
| `AIManager` | Google AI / OpenAI integration |

Each manager has `Mock*Services` and `Production*Services` implementations selected in `Dependencies.swift`.

## Data Sync Pattern

`CoreInteractor.syncAllRemoteDataIfLoggedIn()` performs a full remote→local sync for workout sessions, meal logs, training programs, steps, and body measurements. It posts `Constants.remoteDataSyncDidComplete` via `NotificationCenter` when complete.

## Live Activities

`WorkoutSessionActivityExtension` target provides the Dynamic Island / Lock Screen UI during workouts. Uses `ActivityKit` guarded with `#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)` throughout.

## Onboarding Flow

9-step onboarding under `Core/Onboarding/` (numbered 0–9). Each step is its own VIPER module. Progress is persisted to Firestore. After completion, `AppState.startingModuleId` is updated to `Constants.tabBarModuleId`.
