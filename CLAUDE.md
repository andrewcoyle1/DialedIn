# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development

**Package manager**: Swift Package Manager only — there is no Podfile and no `.xcworkspace`. Open
`DialedIn.xcodeproj` directly; Xcode resolves packages on open.

**Schemes** (there is no scheme called plain `DialedIn`):

| Scheme | Configuration | Backend |
|---|---|---|
| `DialedIn - Development` | Debug | Firebase dev project |
| `DialedIn - Mock` | Mock | All mock services, no Firebase |
| `DialedIn - Production` | Release | Firebase prod project |

**Build from the command line**:
```bash
xcodebuild -project DialedIn.xcodeproj -scheme 'DialedIn - Development' \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

**Run tests**:
```bash
xcodebuild test -project DialedIn.xcodeproj -scheme 'DialedIn - Development' \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

The tests compile and pass (735 tests). Treat a `TEST FAILED` as a regression from your
change.

`-only-testing:DialedInTests` is rejected — the unit-test target's productName is `DialedInTests`
but that is not how the scheme names it, so run the whole `xcodebuild test` and read the counts
from the result bundle:

```bash
xcrun xcresulttool get test-results summary \
  --path "$(ls -td ~/Library/Developer/Xcode/DerivedData/DialedIn-*/Logs/Test/*.xcresult | head -1)"
```

The UI-test runner often fails to launch in the simulator (`FBSOpenApplicationServiceErrorDomain
Code=1`). That does not fail the run — `** TEST SUCCEEDED **` with `failedTests: 0` is the signal
that matters.

Managers take sync engines rather than a services struct, so tests build them through
**`DialedInUnitTests/Support/TestManagers.swift`**, which wires them the way `Dependencies` does
for `.mock` but with `enableLocalPersistence: false` — otherwise each engine opens SwiftData
storage under its `managerKey`, shared between tests and left behind after them.

A sync engine applies a write when its listener next emits, on its own task, so
`currentCollection` and `currentUser` are not up to date the instant `saveDocument` or `signIn`
returns. Assert through `TestManagers.eventually { … }` rather than reading straight after the
call or sleeping for a fixed time. For the same reason a manager holds nothing until it has
signed in, even when its mock remote is already populated.

`UserModel.mock` and the other model mocks are computed properties built from `Date()`, so two
reads of one are never equal — capture the value once and compare against that.

If a build fails with `build.db is locked`, Xcode is building the same DerivedData
concurrently — wait and retry rather than changing anything.

**Deployment target**: iOS 26.0 (26.1 for some targets). The project-level Swift language
version is 6.0; the test and extension targets are still on 5.0.

**Lint** (SwiftLint must be installed):
```bash
swiftlint
```

SwiftLint config (`.swiftlint.yml`): line limit 300, type body 500 lines, file length 750 lines, `trailing_whitespace` disabled.

## First-Time Setup

Copy example files and fill in credentials. All three destinations are gitignored, and the app
will not build or sign in without them:

- `DialedIn/Utilities/Keys.swift.example` → `DialedIn/Utilities/Keys.swift` — 27 constants:
  OpenAI, Mixpanel, RevenueCat, the two Strava values, and 22 `*ManagerKey` strings used as
  local-persistence path names. The manager keys are arbitrary but must stay stable: changing
  one orphans data already persisted under the old name.
- `DialedIn/Info.plist.example` → `DialedIn/Info.plist` — already contains the real reversed
  client IDs for both Firebase projects and the `compound` deep-link scheme, so this is a
  straight copy. Google Sign-In fails at runtime without it.
- `DialedIn/SupportingFiles/GoogleServicePLists/GoogleService-Info-Example.plist` →
  `GoogleService-Info-Dev.plist` and `GoogleService-Info-Prod.plist` (same folder)

## Repository Layout

```
DialedIn/                    # the app target (Core, Components, Managers, Root, Extensions,
                             #   Utilities, SupportingFiles)
WorkoutSessionActivity/      # Live Activity / Dynamic Island widget extension
Shared/                      # code shared between the app and the widget extension
DialedInUnitTests/           # unit tests (target productName is DialedInTests)
DialedInUITests/             # UI tests
functions/                   # Firebase Cloud Functions (Node, Genkit/Vertex AI)
DialedInWatchApp/            # NOT in the Xcode project — orphaned source, does not build
```

`DialedInWatchApp/` is linted but has zero references in `project.pbxproj`, so changes there
affect nothing. Do not treat it as a shipping target.

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

## Package-Provided Infrastructure

Most of the infrastructure layer is **not in this repo**. It comes from the `Swiftful*` SPM
packages and is surfaced through `*+Alias.swift` typealias files so app code never imports the
packages directly:

| Alias file | Provides |
|---|---|
| `Managers/Auth/SwiftfulAuthenticating+Alias.swift` | `AuthManager`, `UserAuthInfo`, `SignInOption`, `MockAuthService` |
| `Managers/Logs/SwiftfulLogging+Alias.swift` | `LogManager`, `LoggableEvent`, `LogType`, the analytics services |
| `Managers/Purchases/SwiftfulPurchasing+Alias.swift` | `PurchaseManager`, `AnyProduct`, `PurchasedEntitlement` |
| `Managers/Routing/SwiftfulRouting+Alias.swift` | `AnyRouter`, `RouterView`, `ResizableSheetConfig` |
| `Managers/DataManagers/SwiftfulDataManagers+Alias.swift` | `CollectionSyncEngine`, `DocumentSyncEngine`, `DataSyncModelProtocol`, the persistence types |
| `Managers/Gamification/SwiftfulGamification+Alias.swift` | `StreakManager`, `ProgressManager`, `ExperiencePointsManager` |
| `Managers/Haptics`, `SoundEffects`, `Utilities` | `HapticManager`, `SoundEffectManager`, `Utilities` |
| `Components/Views/Charts/QuickCharts+Alias.swift` | `TimeSeries`, `TimeSeriesDatapoint`, `ChartScreen`, `LineChart`, `BarChart`, `StackedBarChart`, `ComboChart`, `ChartConfiguration`, `ContributionChart` and its pieces (`ContributionGrid`, `ContributionGridView`, `ContributionLegend`, `ContributionStyle`, `ContributionLayout`, `ContributionCell`) (from `andrewcoyle1/QuickCharts`) |

So when a symbol like `AuthManager` or `CollectionSyncEngine` cannot be found in this
repository, it is a package type — look in the alias file, then the package source. Editing its
behaviour means changing the package, not the app.

**Several of these packages are forks under `andrewcoyle1/`** rather than upstream
`SwiftfulThinking/`: SwiftfulAuthenticating (+Firebase), SwiftfulGamification (+Firebase),
SwiftfulDataManagers (+Firebase), SwiftfulRouting. The forks carry changes the app depends on,
and each `*Firebase` wrapper fork must point its dependency at the matching fork or SwiftPM
reports a conflicting-identity warning for that package.

## Key Managers

App-owned managers live in `DialedIn/Managers/` and are accessed through `CoreInteractor`.
Those marked *(package)* are aliases from the section above, not code in this repo:

| Manager | Purpose |
|---|---|
| `AuthManager` *(package)* | Firebase auth (Apple, Google, anonymous) |
| `UserManager` | Firestore user profile |
| `WorkoutSessionManager` | Logging and syncing workout sessions |
| `WorkoutTemplateManager` | Workout template CRUD + prebuilt seeding |
| `ExerciseModelManager` | Exercise library (local SwiftData + Firestore) + prebuilt seeding |
| `ExerciseUnitPreferenceManager` | Per-exercise weight/distance unit preferences |
| `TrainingProgramManager` | Training programs with local/remote sync |
| `GymProfileManager` | Available equipment per gym |
| `NutritionManager` / `MealLogManager` | Food logging and nutrition targets |
| `FoodManager` / `RecipeTemplateManager` | Food and recipe library |
| `BodyMeasurementsManager` | Body measurements and scale weight |
| `StepsManager` | Daily step history |
| `GoalManager` | User goals |
| `StreakManager` / `ProgressManager` / `ExperiencePointsManager` *(package)* | Gamification |
| `HealthKitManager` / `HKWorkoutManager` | HealthKit read/write |
| `LiveActivityManager` | Dynamic Island / Lock Screen workout tracking |
| `StravaManager` | Strava OAuth and activity import |
| `PurchaseManager` *(package)* | RevenueCat (dev) / StoreKit (prod) |
| `LogManager` *(package)* | Multi-service analytics (Console, Firebase, Mixpanel, Crashlytics) |
| `ABTestManager` | A/B tests via Firebase Remote Config (prod) or local (dev) |
| `AIManager` | Google AI / OpenAI integration via Cloud Functions |
| `PushManager` / `ImageUploadManager` / `ReportManager` | Notifications, image upload, reporting |
| `WorkoutSettingsManager` / `ExerciseSettingsManager` / `FoodLogSettingsManager` | User-facing settings |
| `HapticManager` / `SoundEffectManager` *(package)* | Feedback |

The full registration list is in `Dependencies.init(config:)`; `CoreInteractor` resolves each one
from the container by type.

Each manager has `Mock*Services` and `Production*Services` implementations selected in `Dependencies.swift`.

## Data Sync Pattern

Each manager owns one or more `CollectionSyncEngine` / `DocumentSyncEngine` instances (from
SwiftfulDataManagers) that listen to Firestore and mirror into local persistence, so screens read
the manager's in-memory collection rather than fetching.

`CoreInteractor.syncAllRemoteDataIfLoggedIn()` no longer performs a sync itself — the listeners
already keep data current, so it only posts `Constants.remoteDataSyncDidComplete` via
`NotificationCenter` for screens that want to refresh derived state. Treat it as "tell everyone
to re-read", not "go fetch".

## Live Activities

`WorkoutSessionActivityExtension` target provides the Dynamic Island / Lock Screen UI during workouts. Uses `ActivityKit` guarded with `#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)` throughout.

## Onboarding Flow

Onboarding lives under `Core/Onboarding/`, in folders numbered by step: `0 - WelcomeView`
through `9 - OnboardingCompleted` (there is no `7 -`, and both `9 - StravaConnect` and
`9 - OnboardingCompleted` share the 9 prefix). Each step is its own VIPER module. Progress is
persisted to Firestore. After completion, `AppState.startingModuleId` is updated to
`Constants.tabBarModuleId`.

`UserModel.inferredOnboardingStep` derives the resume point from the stored profile, and any
screen that needs to resume onboarding routes via **`OnboardingStepRouter`**
(`Core/Onboarding/OnboardingStepRouter.swift`): a protocol whose extension holds the single
`routeToOnboardingStep(_:onComplete:)` switch. Six presenters used to carry their own copies of
that switch and had drifted out of sync. Add new steps there, not in a presenter.

## Body Measurements

The eighteen circumference measurements (neck, waist, left bicep, …) are **one** VIPER module,
not eighteen. `BodyMeasurementKind`
(`Core/Analytics/Subviews/BodyMetrics/LogMeasurement/BodyMeasurementKind.swift`) is a table with
one line per measurement carrying everything that differs: display name, cm and inch picker
ranges, the two defaults, the `KeyPath` that reads it off `BodyMeasurementEntry`, and the
`CircumferenceUpdate` that writes it back. `LogMeasurementView` and its presenter are driven by
that kind, and `BodyMetricsRouter` exposes a single `showLogMeasurementView(kind:)`.

To add a measurement: add a field to `BodyMeasurementEntry` with its `CircumferenceUpdate` and
`ClearedField` cases, then add one line to the `BodyMeasurementKind` table. Do not copy a module.

The detail screens behind those loggers are collapsed the same way:
`MeasurementDetails/BodyMeasurementDetail.swift` holds one `MetricDetailPresenter` for all
eighteen, reached by `showBodyMeasurementDetailView(kind:themeColor:)`. `BodyRatioMetric` and
`VisualBodyFatMetric` are genuinely different and stay as their own files.

`BodyMeasurementKind` is the **only** table for these eighteen. `BodyMetricType` (which also
covers `scaleWeight` and `visualBodyFat`, so it cannot simply be replaced) maps into it via
`measurementKind`, and its `value(from:)` and `displayTitle` defer to that rather than keeping
their own keypath and title dictionaries.

Together these two passes removed ~7,400 lines across 90 files whose only real differences were
the values now in the table.

## Backend (Cloud Functions)

`functions/` holds Firebase Cloud Functions v2 (Node, ES modules) using Genkit with Vertex AI.
Six `onCall` callables, all in `us-central1`: `foodAnalyze`, `mealDescribe`,
`nutritionLabelAnalyze`, `chatGenerate`, `imageGenerate`, `foodSearch`.

All six share `CALLABLE_OPTIONS = { region: REGION, enforceAppCheck: true }` and call
`requireAuth(request)`, which throws `unauthenticated` when `request.auth` is missing. Keep both
on any new callable — they are the only thing stopping an arbitrary rebuilt client from calling
the backend, since the API keys in the bundled plists are public by design.

App Check on the client is wired in `DialedIn/Utilities/AppCheckProviderFactory.swift`:
App Attest where available, DeviceCheck as fallback, and a debug provider for simulators. A
simulator debug token must be registered in the **dev** Firebase project only, never prod.

Two things live outside the code and are easy to miss:
- App Check **enforcement** is a per-service toggle in the Firebase console, separate from the
  `enforceAppCheck` flag here.
- Enabling enforcement breaks already-shipped app versions that predate the App Check wiring.
  Check App Check metrics for unverified traffic before turning it on.

Deploy with `firebase deploy --only functions` — this is not part of the Xcode build, so changes
under `functions/` have no effect until deployed.

## Code Health Baseline

As of the latest commit on `development`, all three schemes build with **zero warnings** and
`swiftlint` reports **zero violations** across 1,201 files. Treat any new warning as something to
fix rather than accumulate.

Two deliberate suppressions exist, each documented at the site:
- `Dependencies.swift` disables `type_body_length`/`file_length` — it is one long DI root whose
  switch arms bind ~32 locals that a shared registration block consumes.
- `StravaManager.swift` scopes an iOS 26 deprecation on `presentationAnchor(for:)`, because every
  spelling of a scene-less `UIWindow` is deprecated and Swift has no per-call suppression.
