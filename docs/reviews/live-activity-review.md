# Live Activity — full review (23 Sep 2026)

Scope: the whole feature as it stands on `feature/live-activity-redesign` (11 commits plus the
uncommitted `RestRing` change): `Shared/`, `WorkoutSessionActivity/`,
`Managers/LiveActivities/`, `Managers/Training/WorkoutRestTimerIntents.swift`, the rest timer in
`HKWorkoutManager`, the tracker presenter's Live Activity wiring, `AppDelegate`, and the nine
test suites. Lenses: correctness, spec conformance (`docs/specs/live-activity.md`),
over-engineering, test gaps.

Verification: the Development scheme builds clean. The ten Live Activity / tracker suites were
run on the iPhone 17 simulator: **129 tests, 125 passed, 4 failed**. Two of the failures are on
the branch tip (F3 below). The other two were a throw-away probe I wrote to confirm F2 and F3;
it has been deleted. The full suite was not run. Nothing was run on device; the Lock Screen and
Dynamic Island were not screenshotted.

The work packages for fixing all of this are in `docs/specs/live-activity-work-packages.md`.

---

## 1. Correctness findings, most severe first

### F1 · HIGH · After a cold launch, no handler action reaches the activity  (CONFIRMED by reading)

`LiveActivityManager.currentActivity` is set only by `ensureLiveActivity` / `startLiveActivity`,
which are called from `WorkoutTrackerPresenter.init` and `CoreInteractor.startWorkoutSession`.
A `LiveActivityIntent` tapped after iOS has evicted the app launches a fresh process that runs
`AppDelegate` and the handler but never a tracker screen, so `currentActivity` is nil.

Every handler action ends in `push(_:exerciseIndex:)` →
`LiveActivityManager.updateLiveActivity(contentState:)`, which hits
`guard let activity = self.currentActivity` (`LiveActivityManager.swift:230`), logs
`updateLiveActivityFail(noUpdatableActivity)` and returns. The session is saved; the Lock Screen
is not updated.

What the user sees: they tap Complete. `CompleteSetIntent` pushes its optimistic state, which
with a handler present has **no rest and the same `targetSetId`** (`applyRestLogic` leaves
`restEndsAt` alone; nothing changes the target). The banner shows the same set again. They tap
again; the handler drops it (`completedAt != nil`). They are stuck until they open the app.
`endLiveActivity` → `endActivity` has the same guard, so Finish from the Lock Screen after a
cold launch ends the session but leaves the activity on screen.

Commit a79d58fa fixed the cold-launch *rest lookup* (`runningRestEndTime` falls back to the app
group) but not the activity handle. `LiveActivityScenarioTests` cannot see this: it asserts on
`lastContentState`, which is assigned at line 228, **before** the guard.

Fix: the handler's `push` should call `ensureLiveActivity(...)` (it already finds the activity by
session id and updates it), and `endActivity` should resolve
`Activity<WorkoutActivityAttributes>.activities.first { $0.attributes.sessionId == … }` when
`currentActivity` is nil. Move `lastContentState = contentState` below the guard. Add a rig
assertion that no `LiveActivityMan_UpdateLiveActivity_Fail` event was logged.

### F2 · HIGH · A unilateral last exercise shows "All sets complete" with a row still to do  (CONFIRMED by probe test)

`computeTotals` counts completed sets as
`sets.filter { $0.completedAt != nil }.pairedSetCount` (`LiveActivityManager.swift:514`).
`pairedSetCount` deliberately counts a lone left row as one set. So once every other set is done
and the **left** half of the last pair is logged, `completedSetsCount == totalSetsCount`,
`isAllSetsComplete` is true, and phase row 3 wins over row 7: the banner shows the green tick,
"All sets complete" and a **Finish** button while the right row is still pending. Tapping Finish
ends the workout with that row unlogged.

Probe (`2L, 2R` last pair, `2L` done): `state.targetSetId == "2R"`, `isAllSetsComplete == true`,
phase `.allSetsDone`. Commit a2662482 fixed the same shape for `.exerciseDone` (via
`fullyCompletedRows`) but only for the per-exercise position, not the whole-workout totals.
The scenario test's unilateral exercise is the second of four, so it never trips this.
`progress` overshoots the same way, and the tracker's `completedSetsFraction` reads 24/24 early
(display only).

Fix: `computeTotals` and `endLiveActivity`'s `completedSetsCount` should count
`Self.fullyCompletedRows(in: $1.sets).pairedSetCount`. Keep the probe as a real test.

### F3 · MEDIUM · Two tests fail on the branch tip: "Warmup set 1 of 2" vs "Warmup 1 of 2"

`SetPosition.label` (`Shared/LiveActivityPhase.swift:113`) renders `"Warmup set 1 of 2"`.
`LiveActivityPhaseTests:262` and `LiveActivityScenarioTests:173` expect `"Warmup 1 of 2"`, as
does spec §2. Commit d07f5bc9 changed one side and not the other. Pick "Warmup 1 of 2" (spec, and
shorter on a 38-pt row).

### F4 · MEDIUM · Finish from the Lock Screen while the tracker is open leaves a zombie screen that resurrects the session

`AppLiveActivityIntentHandler.completeWorkout` clears `activeSession`. The tracker presenter,
still alive in the background, guards `adoptSavedSessionIfChanged` with
`guard let saved = interactor.activeSession` → nil → no-op. When the user returns, the tracker
still shows the finished workout; the next edit fires `workoutSession.didSet` →
`saveWorkoutProgress()` → `updateActiveSession(...)` and the ended session is active again.

Also, `completeWorkout` re-implements the tracker's finish rather than sharing it and drifts:
no retry on a transient save failure (`WorkoutTrackerPresenter+Finish`), no
`preCompleteConsecutiveRestDays`, no `setActiveWorkoutGymProfile(nil)`. If the save throws, HK
has already been ended and `hkStartedSessionId` cleared, so reopening the tracker starts a second
HealthKit session for the same workout.

Fix: when the observed `activeSession` becomes nil and it was this screen's session, dismiss the
tracker. Extract one finish routine both callers use.

### F5 · MEDIUM · HKWorkoutManager ends the activity with a stale session, racing the real end  (PLAUSIBLE)

`consumeSessionStateChange` (`HKWorkoutManager.swift:219–233`) calls `endLiveActivity` with
`activeSessionModel`, which is captured once in `startWorkout(workout:)` and never updated, so it
holds zero completed sets and no volume. Both finish paths (tracker and handler) call
`hkWorkoutManager.endWorkout()` first, then save, then `endLiveActivity` with the real session.
HealthKit's `endCollection`/`finishWorkout` is usually faster than a Firestore write, so the stale
end can land first; an ended activity ignores the second `end`, and the summary on the Lock
Screen shows 0 sets. Not reproducible in tests (no HK session).

Fix: delete both `endLiveActivity` calls from `consumeSessionStateChange`. Every path that ends a
workout already ends the activity itself. Discard is safe: `discardWorkout` nils
`activeSessionModel` before stopping.

### F6 · MEDIUM · Starting a rest pushes "no rest" then "rest" from two unordered Tasks

`startRest` calls `cancelRest()` (`HKWorkoutManager.swift:372`), which enqueues
`updateRestAndActive(restEndsAt: nil)` inside `Task { @MainActor in … }`. `startRest` then
synchronously calls `updateLiveActivity(params:)`, which enqueues its own `Task` for the real
push. Two unstructured tasks; FIFO in practice but not guaranteed. In practice the Lock Screen
gets a "Rest over · Complete" frame before every countdown (Complete, +15s); if they ever
reorder, the countdown vanishes while the manager's timer runs on. Commit a79d58fa's "paused
flash" was this same shape.

`updateRestAndActive` is also the odd one out: it rebuilds from `activityViewState?.contentState`
(only refreshed when ActivityKit's `contentUpdates` stream emits), bypasses the equality gate,
logs nothing, and does not record `lastContentState`.

Fix: split the timer cancel from `cancelRest()`'s push so `startRest` cancels only the timer;
make `updateRestAndActive` build from `lastContentState` and go through
`updateLiveActivity(contentState:)`.

### F7 · LOW · `.exerciseDone` names the wrong exercise

`LiveActivityPhaseContent` line 62–64: `case let .exerciseDone(name, firstTarget):
doneRow(text: "\(name) done")`. The phase's first payload is `next` — the *next* exercise's
name — so after finishing Bench press the banner reads "✓ Incline press done · Next: Incline
press". The phase is nearly unreachable now (see F11), which is why nobody has seen it.

### F8 · LOW · `CompleteSetIntent` does three ActivityKit updates per tap and can flash Finish

`updateLoading` (isProcessingIntent true) → `pushUpdate` (optimistic, isProcessingIntent false)
→ handler's push. The loading state is visible for microseconds and the button is re-enabled
before the handler has done anything. `applyOptimisticProgress` adds one to
`completedSetsCount` per **row**, which for pairs overshoots and can set `isAllSetsComplete`
one row early: a momentary `.allSetsDone` with a Finish button until the handler's push corrects
it. Live Activities have an update budget; three per tap is spending it.

Fix: with a handler, push only the loading state and let the handler's push clear it (its state
has `isProcessingIntent: false`). Keep the optimistic path for the no-handler fallback, or delete
the fallback (D1).

### F9 · LOW · Weight is always shown in kilograms

`LiveActivityLayout.weightUnit = .kilograms` with a "follow-up" comment. A user with a per-exercise
lb preference sees kg on the Lock Screen and lb on the tracker. `ContentState` needs a
`weightUnit`, filled from `ExerciseUnitPreferenceManager.getPreference(templateId:)` for the
current exercise.

### F10 · LOW · `Date()...until` traps when `until` has just passed

`RestRing` and the compact-trailing countdown build `Date()...until`. `.resting` is derived with
`restEndsAt > now` a few microseconds earlier; if the rest ends in between, `ClosedRange`'s
precondition fires and the widget process crashes (blank activity). Narrow, but free to close:
`Date()...max(until, Date())`.

### F11 · LOW · `exerciseIndexWithWorkLeft` only searches forward

With exercise A skipped and B, C finished, the tracker's `liveActivityExerciseIndex` (expanded =
C) → `exerciseIndexWithWorkLeft(2)` finds nothing later → C, no target → `.exerciseDone(next:
"C")` or `.unknown`, while A still has sets. Fall back to the first exercise with work anywhere.
Once that holds, `.exerciseDone` is unreachable from the app (the manager always points at work
left) and can be deleted with its five `nextExercise*` fields (D6).

### F12 · LOW · `startLiveActivity` adopts any existing activity

`firstExistingActivity()` returns `Activity.activities.first` regardless of session. A leftover
activity from a previous workout (app killed mid-workout, new workout started) is adopted with
the old `workoutName` in its attributes. Filter by `sessionId` and end the others.

### F13 · LOW · `onScenePhaseChange` never fires

`newPhase == .active && oldPhase == .background` cannot match: iOS goes background → inactive →
active. Harmless today because the observation path already re-reads the session, but it is dead
code that looks like a safety net. Condition should be `newPhase == .active`.

### F14 · LOW · `lastContentState` recorded before the no-activity guard

`LiveActivityManager.swift:228`. A push that fails for lack of an activity still records its
state, so an identical retry is suppressed by the equality gate. Move it below the guard (part of
F1).

Not a finding, checked and fine: cold-launch settings. `DocumentSyncEngine` and
`CollectionSyncEngine` restore their last document/collection from local persistence in `init`,
so the handler gets the user's rest settings, per-exercise overrides and exercise types without
`logIn()` ever running.

---

## 2. Spec conformance (`docs/specs/live-activity.md`)

| § | Spec says | Code does | Action |
|---|---|---|---|
| 2 | `SetPosition` label "Warmup 1 of 2" | "Warmup set 1 of 2" | F3: change code |
| 2 row 6 | `.exerciseDone` when the exercise is finished and more follow | Manager always advances to the next exercise with work, so the phase is only reachable through F11's edge | Delete row 6 (D6) or document it as unreachable |
| 3 `.resting` | Row 1 falls back to exercise/position when there is no `logged` set ("rest started from the app for a set logged there") | Manager derives `lastLogged*` from the most recently completed set during **any** rest, so the correction window is open for app-logged sets too. The fallback only shows during an intent's optimistic frame | Update §3/§4: the window is any running rest |
| 4 | `AdjustLastSetRepsIntent` writes `pendingSetAdjustment`; app consumes it in the session manager | v1.1: handler applies it in-process; the slot is fallback-only | Mark §4 "State/Intent" as superseded by §7 |
| 6 | `WorkoutSessionManagerTests` consume a pending adjustment | No such tests; obsolete under §7 | Drop from §6 |
| 6/7.4 | Intent tests: with a handler, `CompleteSetIntent` calls it and writes no slot; without, it writes the slot | Not written (needs a live `Activity`) | Either extract the decision or delete the fallback (D1) and the requirement |
| 7.4 | `WorkoutTrackerPresenterTests`: changed session adopted; in-flight update not overwritten | Adoption tests exist; the in-flight guard (`isProcessingUpdateSet`) has no test | Add one |
| 7.5 | Ring with `.labelsHidden()` and `Text(timerInterval:)` beside it at body size | Uncommitted change: label suppressed via empty `currentValueLabel`, countdown drawn inside the ring, bare ring in the compact slots | Commit it; rewrite §7.5 and the §3 `.resting` row |
| 8 | Per-side sets out of scope, shown as one target | Pairs are handled throughout (`pairedSetCount`, `fullyCompletedRows`) | Update §8 |

Everything else in §3, §5 and §7.1–7.3 matches.

---

## 3. Over-engineering and deletions (Ponytail), largest first

| # | What | Why it can go | ≈ lines |
|---|---|---|---|
| D1 | The three fallback slots (`PendingSetCompletion/Adjustment/WorkoutCompletion` in `SharedWorkoutStorage`), `drainFallbackSlots`/`drain`/`setReps` in the handler, every `if handler == nil` branch in the four intents, `applyRestLogic(fabricatingRest:)`, `buildPendingSetCompletion`, 3 drain tests | A `LiveActivityIntent` runs in the app process after `didFinishLaunching`, which registers the handler. The "perform beats launch" race the code defends against cannot occur. Spec §7.2 already says "never, in practice" | 250 |
| D2 | `HKWorkoutManager.syncRestEndTimeFromSharedStorage` + the call in `startWorkoutTimer` + 3 tests | Only the fallback intents ever wrote the shared rest from outside the app. Keep the `restEndTime` **write**: the handler reads it after a cold launch | 60 |
| D3 | `ActivityViewState`, `activityViewState`, `CoreInteractor.liveActivityViewState`, push-token observation, `Data.hexadecimalString`, `pushType: .token` → `nil`; `observeActivity` shrinks to the dismissed→cleanup branch | Zero readers outside the manager; push updates are out of scope (§8) | 70 |
| D4 | `SendableActivity` private wrapper in `LiveActivityManager` | `Activity+Sendable.swift` already declares the retroactive conformance; two fixes for one warning | 25 |
| D5 | `ContentState.statusMessage`, `.totalVolumeKg`, `.endedSuccessfully`, `.lastIntentTimestamp`, `.finalTotalExercisesCount`; `LiveActivityUpdateParams.totalVolumeKg/elapsedTime`; `MakeContentStateParams` overrides (`elapsedTimeOverride` is not even read) | Never rendered. `statusMessage` is threaded through ten call sites for nothing | 80 |
| D6 | `.exerciseDone` phase, its two rows, the five `nextExercise*` fields, `deriveNextExerciseData`, 3 tests | Unreachable once F11 is fixed; F7 shows nobody sees it | 100 |
| D9 | Preview content states `stale`, `someMetrics`, `previewOld` and the six `#Preview`s in `WorkoutSessionActivity.swift` | Built for the old view; none shows a phase the new banner has | 120 |
| D7 | `CoreInteractor+LiveActivity.endActivity(with:)`, `.updateRestAndActive`, `.discardLiveActivity`; the tracker's discard calls `discardLiveActivity()` then `endLiveActivity(...)`, and the second is a no-op on an ended activity | No callers / dead second call. Discard should just be `endLiveActivity(isCompleted: false)` (already `.immediate`) | 40 |
| D8 | `WorkoutSessionManager.restEndTime` and the `#else` branch of `CoreInteractor.restEndTime` | Never written | 8 |
| D12 | `Shared/ElapsedTimeView.swift` (no references), `Shared/MetricsModel.swift` (app-only) | Not shared | 30 + move |

Kept on purpose: `LiveActivityUpdating` (the one test seam that makes the rest timer and handler
testable), `LiveActivityIntentHandling` (widget/app boundary), the `#if canImport(ActivityKit)`
stubs (`SUPPORTS_MACCATALYST = YES` on the app target), `RestDurationRules`.

Net: roughly 780 lines removable, most of it dead by construction rather than by opinion.

---

## 4. Test coverage gaps

| # | Behaviour with no failing test | Where it belongs |
|---|---|---|
| T1 | A push dropped for lack of an activity (F1). The scenario rig should fail when `_UpdateLiveActivity_Fail` is logged | `LiveActivityScenarioTests` rig, via a spy `LogService` |
| T2 | Unilateral **last** exercise: left half of last pair → not `.allSetsDone` (F2) | `LiveActivityManagerTests` (the deleted probe, verbatim) |
| T3 | Finish from the activity while the tracker is open: tracker dismisses, no resurrection (F4) | `WorkoutTrackerPresenterTests` |
| T4 | `startRest` never emits a nil-rest update between cancel and start (F6) | `HKWorkoutManagerRestTests`, on `LiveActivityUpdaterSpy` call order |
| T5 | `CompleteSetIntent`'s optimistic functions are `fileprivate` and untestable; the overshoot in F8 is invisible | Make them internal or delete with D1/F8 |
| T6 | Weight unit reaches the label (F9) | `LiveActivityManagerTests` |
| T7 | `RestDurationRules` has no direct tests (only through the handler): warm-up scaling, last warm-up with `restAfterLastWarmUp` off, side pair, last working set, zero override | New `RestDurationRulesTests` |
| T8 | `WorkoutTrackerPresenter.isProcessingUpdateSet` guard (spec §7.4) | `WorkoutTrackerPresenterTests` |
| T9 | `onScenePhaseChange` adopts on foreground (F13) | `WorkoutTrackerPresenterTests` |

The phase derivation, the label formatting, the handler and the rest timer are well covered.
The gap is at the ActivityKit boundary, which is exactly where F1 lives.

---

## 5. Uncommitted change (`RestRing` countdown inside the ring)

Reads correctly: empty `currentValueLabel` removes the system's own countdown, the overlay is
sized off the ring, and the compact slots pass `showsCountdown: false`. Two notes: the doc
comment has a duplicated first line ("The circular rest countdown." / "The rest countdown as a
ring…"), and it needs F10's range guard and the §7.5 spec rewrite. Commit it as its own change.
