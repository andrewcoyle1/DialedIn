# Live Activity — redesign spec (v1)

Replaces the lock-screen banner and Dynamic Island views in `WorkoutSessionActivity/` and adds
the one piece of state and the one intent they need. Builds on `WorkoutActivityAttributes`
(`Shared/`), `LiveActivityManager` and the intents in `Managers/Training/WorkoutRestTimerIntents.swift`.

## 1. Purpose

The activity is read with one thumb while the other hand is holding a weight. At any instant it
answers **one question** and offers **one action**. Everything else is noise and is cut.

Two things the current view gets wrong that this fixes:

- **A missed set is recorded as a hit.** `CompleteSetIntent` logs the prescribed reps as done.
  Smart progression reads that log, so a set that fell short of the target progresses the
  weight anyway. The redesign lets the user correct the reps of the set they just logged,
  during the rest that follows it, and nowhere else.
- **The best row is spent on the app icon and the workout name.** The user started the workout;
  neither tells them anything. The header goes. The workout name appears once, on the summary.

## 2. The phase model

The view no longer branches on booleans inline. A pure derivation turns the content state into
one of eight phases, and each phase has one layout. `Phase` lives in `Shared/` so the widget and
the tests both see it.

```swift
enum LiveActivityPhase: Equatable {
    case ready(target: SetTarget, position: SetPosition)          // about to lift
    case resting(until: Date, next: SetTarget?, logged: LoggedSet?) // countdown running
    case restOver(next: SetTarget)                                  // rest passed, phone untouched
    case exerciseDone(next: String, firstTarget: SetTarget?)        // this exercise finished, more to come
    case allSetsDone                                                // nothing left but Finish
    case paused                                                     // isActive == false
    case ended(Summary)                                             // isWorkoutEnded
    case unknown                                                    // no exercise, no target
}
```

`LiveActivityPhase(state:now:isStale:)` is the only derivation, in this precedence:

| Order | Condition | Phase |
|---|---|---|
| 1 | `isWorkoutEnded` | `.ended` with the `final*` fields |
| 2 | `!isActive` | `.paused` |
| 3 | `isAllSetsComplete` | `.allSetsDone` |
| 4 | `restEndsAt > now` | `.resting(until:next:logged:)` — `next` is the current `target*` fields (after `CompleteSetIntent` they already describe the next set), `logged` is `lastLogged*` |
| 5 | `restEndsAt != nil && restEndsAt <= now`, or `isStale` | `.restOver(next:)` |
| 6 | `currentExerciseCompletedSetsCount == currentExerciseTotalSetsCount && currentExerciseIndex + 1 < totalExercisesCount` | `.exerciseDone` |
| 7 | `targetSetId != nil` | `.ready` |
| 8 | otherwise | `.unknown` (renders like `.paused` without the label) |

`SetTarget` here is a display value: `weightKg`, `reps`, `durationSec`, `distanceMeters`, formatted
by one `label` in the same shape the tracker's Prev column uses (`60 kg × 8`, `12`, `1:30`,
`400 m 10:00`). `SetPosition` is `(index, total, isWarmup)` for "Set 2 of 4", counted within the
group the next set belongs to: "Warmup 1 of 2" through the warm-ups, then "Set 1 of 4".

## 3. Lock-screen banner

Fixed height across phases so the banner does not jump when a set completes. Two rows plus a
1-pt progress line along the bottom edge (`progress`), which is the only whole-workout indicator.

| Phase | Row 1 | Row 2 |
|---|---|---|
| `.ready` | exercise image · **Exercise name** · `Set 2 of 4` | **60 kg × 8** · [✓ Complete] |
| `.resting` | `Logged 60 kg × 8` · [−] [+] on reps | rest ring + countdown · `Next 60 kg × 8` · [+15s] [Skip] |
| `.restOver` | exercise image · **Exercise name** · `Set 3 of 4` | `Rest over` · **60 kg × 8** · [✓ Complete] |
| `.exerciseDone` | ✓ **Exercise name** done | `Next: Incline press` · `60 kg × 8` |
| `.allSetsDone` | ✓ **All sets complete** | [Finish] |
| `.paused` | exercise image · Exercise name, dimmed | `Paused` · `Resume in the app` |
| `.ended` | ✓ **Workout name** | Duration · Sets · Volume (volume only if > 0) |

Rules:

- One prominent button per phase, never two. Skip and +15s are `.bordered`; Complete and Finish
  are `.borderedProminent`.
- Row 1 in `.resting` is the **correction window** (§4). When there is no `logged` set (rest
  started from the app for a set logged there) row 1 shows exercise name and position instead.
- The exercise image is kept: recognition beats reading at a glance. 38 pt, rounded 6.
- Text colours are semantic (`.primary`, `.secondary`, `.green` for done). Labels on
  `.borderedProminent` use `colorScheme.foregroundSecondary` because the widget's accent is the
  label colour; see §7 on changing that instead.
- Nothing shows the elapsed workout time, total volume, the status message, or the −15s button.

## 4. Correcting the logged set

`CompleteSetIntent` continues to log the prescribed set and start the rest; that keeps the
pre-lift state to one button. Correction happens **during the rest**, when both hands are free and
the number is fresh, and closes when the rest ends or the next set is logged.

### State

Three fields on `ContentState`, written by `CompleteSetIntent` (optimistically) and by
`LiveActivityManager` when the app logs a set itself:

```swift
var lastLoggedSetId: String?
var lastLoggedReps: Int?
var lastLoggedWeightKg: Double?   // display only; weight is not editable here
```

`LiveActivityManager` clears all three when the rest ends or a new `targetSetId` becomes current.

### Intent

```swift
struct AdjustLastSetRepsIntent: LiveActivityIntent {
    @Parameter var delta: Int     // −1 or +1
}
```

- No-op unless the activity's state has `lastLoggedSetId` and `restEndsAt > now`.
- Clamps `lastLoggedReps + delta` to `0...99`.
- Writes `SharedWorkoutStorage.pendingSetAdjustment = (setId, reps, adjustedAt)` — a new slot
  beside `pendingSetCompletion`, same shape, same clearing rules — and updates the activity
  optimistically so the label changes at once.
- The app consumes it where it consumes `pendingSetCompletion` today (`HKWorkoutManager` /
  `WorkoutSessionManager`): find the set by id in the active session, set `reps`, save. If the
  set is not found (session changed underneath), drop it silently.
- Repeated taps coalesce: the slot holds the latest reps, not a queue of deltas.

### What it does not do

Weight, RPE, duration and distance are not editable from the activity. A rep count is the one
number a user knows the instant a set ends; everything else is an app decision.

## 5. Dynamic Island

The island is always rendered on black; it uses semantic colours and never reads the scheme.

| Region | Content |
|---|---|
| Minimal | rest ring while `.resting`; ✓ in `.allSetsDone`; exercise image otherwise |
| Compact leading | exercise image, or rest ring while resting |
| Compact trailing | `60 kg × 8` in `.ready`/`.restOver`; countdown while resting; `Done` in `.allSetsDone` |
| Expanded | the banner's two rows for the current phase, minus the progress line, minus `.ended` (the island is dismissed on end) |

## 6. Tests

- `LiveActivityPhaseTests` (`DialedInUnitTests/`): one case per row of the §2 table, plus:
  ended beats paused; paused beats resting; `isStale` with a live `restEndsAt` still gives
  `.restOver`; rest with no `lastLoggedSetId` gives `.resting(logged: nil)`; last exercise with all
  its sets done gives `.allSetsDone`, not `.exerciseDone`.
- `SetTargetLabelTests`: the four tracking shapes, kg and lb, nil pieces omitted.
- `AdjustLastSetRepsIntentTests`: writes the pending adjustment with the clamped reps; no-op
  without a logged set; no-op after the rest ends; two taps leave one slot holding the latest.
- `WorkoutSessionManagerTests`: consuming a pending adjustment updates that set's reps and
  nothing else; an unknown set id is dropped.
- `LiveActivityManagerTests`: completing a set from the app populates `lastLogged*`; the rest
  ending clears them.

No UI tests. The phase derivation is where the behaviour lives; the views are one switch each.

## 7. In-process intent handling (v1.1, replaces the shared-storage hand-off)

A `LiveActivityIntent` runs **in the app's process**: the system launches or wakes the app in the
background and calls `perform()` there. The v1 hand-off ignored that. Each intent wrote a
"pending" slot into the app-group defaults, and a one-second timer inside the same process read
it back — a timer that only started once HealthKit's `beginCollection` succeeded, so on the
simulator and for any user who declined HealthKit nothing the widget wrote was ever consumed. A
rest started from the widget also had no branch in the app's rest sync, so it never started the
app's timer even when polling ran.

### 7.1 The handler

```swift
// Shared/
@MainActor protocol LiveActivityIntentHandling: AnyObject {
    func completeSet(id: String) async
    func adjustLastSetReps(id: String, delta: Int) async
    func adjustRest(by seconds: Int) async
    func skipRest() async
    func completeWorkout() async
}

@MainActor enum LiveActivityIntentHandler {
    static weak var current: (any LiveActivityIntentHandling)?
}
```

The app registers one implementation when `Dependencies` is built (the background launch for an
intent runs `AppDelegate` first, so it is in place before any `perform()`), built on the managers
it already has:

- `completeSet(id:)`: find the set in `workoutSessionManager.activeSession`; fill weight, reps,
  duration and distance from its own target values (not from the activity's `target*` fields),
  set `completedAt`, save through `updateActiveSession`; then start the rest through
  `HKWorkoutManager.startRest` with the duration the set-row presenter would have used
  (`WorkoutSettings.restDurationsByExerciseType`, per-exercise override, default — extract that
  lookup from `SetTrackerRowPresenter.baseRestDuration(for:)` into a shared helper so both call
  one function); then push the Live Activity from the saved session.
- `adjustLastSetReps(id:delta:)`: the set must exist and the rest must be running
  (`HKWorkoutManager.restEndTime > now`); clamp `reps + delta` to `0...99`, save, push.
- `adjustRest(by:)` / `skipRest()`: the existing `HKWorkoutManager` rest calls, then push.
- `completeWorkout()`: the existing end path the tracker's Finish uses.

Every action ends with a push from the saved session, so the app is the single source of truth
for the activity. The intent's optimistic update covers only the gap until that push lands.

### 7.2 The intents

Each intent is a thin wrapper: apply the optimistic state as today, then
`await LiveActivityIntentHandler.current?.<action>`. When no handler is registered (never, in
practice — the app is the process) the intent falls back to the v1 shared-storage write so the
behaviour degrades rather than disappears.

### 7.3 What goes

- `HKWorkoutManager`'s per-second polling of `pendingSetCompletion`, `pendingSetAdjustment` and
  `pendingWorkoutCompletion`, and the three properties and clear methods on it, the session
  manager, `CoreInteractor` and `WorkoutTrackerInteractor`.
- `WorkoutTrackerPresenter.startObservingPendingCompletions` and the three `sync…FromWidget`
  methods. In their place the presenter observes `interactor.activeSession` and, when a saved
  session arrives that differs from its own copy and it is not mid-update itself, adopts it —
  that is how a set logged by the handler appears on screen while the tracker is open.
- `SharedWorkoutStorage.pendingSetCompletion/Adjustment/WorkoutCompletion` stay only as the
  fallback slots in §7.2; nothing in the app reads them any more. `restEndTime` stays: the widget
  itself does not read it, but the existing rest sync does, and removing that is out of scope.

### 7.4 Tests

- `LiveActivityIntentHandlerTests`: with `TestManagers`, `completeSet` marks exactly that set
  complete with its own targets, starts a rest of the settings-derived duration, and pushes an
  activity update whose `lastLogged*` name it; `adjustLastSetReps` changes only reps, clamps, and
  is a no-op with no running rest or an unknown id; `skipRest`/`adjustRest` reach the HealthKit
  manager; `completeWorkout` ends the session.
- Intent tests: with a handler registered, `CompleteSetIntent` calls it and writes no shared
  slot; with none, it writes the slot as before.
- `WorkoutTrackerPresenterTests`: a changed `activeSession` from the interactor is adopted;
  the presenter's own in-flight update is not overwritten.
- Removed polling: `HKWorkoutManagerTests` no longer reference the pending properties.

### 7.5 Duplicate countdown

`ProgressView(timerInterval:countsDown:)` in the circular style draws the remaining time as its
own label. The banner and island show it once: the ring with `.labelsHidden()`, and the
`Text(timerInterval:)` beside it at body size.

## 8. Out of scope

Editing weight, RPE or duration from the activity; per-side (left/right) sets, which show as one
target; the Apple Watch; push-driven updates from the server; and changing the widget's
`AccentColor` asset away from `labelColor`. That last one is worth doing separately: with a real
accent the prominent labels can drop their explicit inverse colour.
