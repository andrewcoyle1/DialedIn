# Dead settings audit

Every stored property on every settings model in the app, and whether anything outside the screen
that writes it ever reads it.

## Summary

- **69 stored settings** across six documents: `WorkoutSettings` (23), `FoodLogSettings` (29),
  `NutritionStrategySettings` (13), `ExerciseSettingsModel` (2), `AnalyticsSettings` (1),
  `ShortcutSettings` (1).
- **26 are dead** — saved to Firestore and read by nothing outside the screen that writes them.
  That is a little more than the twenty-five this audit set out to confirm.
- **43 are live.**
- **Three screens are wholly inert**: Time Selection, Favourite Measurements and Optimisation.
  Every control on them writes a field no other code reads. Two more, **Strategy Settings** and
  **Expenditure Settings**, are inert but for one field: `bmrEquation`, which `NutritionManager`
  does read. And **Smart Progression Settings** is inert in full — there is no smart-progression
  engine in the app for its three fields to steer.

### What "read by" means here

A read counts only if it is production code that is **not** the settings screen that writes the
value. Reads in `#Preview` blocks, in tests, and in the writing screen's own presenter or view are
excluded: a toggle that renders its own state and nothing else is still a toggle that does nothing.
Where a setting is surfaced through a helper (`AnalyticsSettings.isVisible(_:)`,
`ShortcutSettings.quickActions`) the helper's callers are what was traced, not the stored property.

### Verdicts

- `wire` — there is an obvious place it should take effect, named in the row.
- `remove` — nothing in the app plausibly consumes it.
- `decide` — genuinely ambiguous; it needs the feature it describes to exist first, or the product
  owner to say what it should mean.

---

## Workout Settings

`DialedIn/Managers/Training/WorkoutSettings/Models/WorkoutSettings.swift` — document
`workout_settings`, one per user.

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| `propagateChanges` | `WorkoutSettings` | `WorkoutSettingsPresenter.propagateChanges` | `WorkoutTrackerPresenter.propagateChanges(_:)` | live |
| `rirTracking` | `WorkoutSettings` | `WorkoutSettingsPresenter.rirTracking` | `WorkoutTrackerPresenter.showRIRTracking` | live |
| `exerciseAutoNext` | `WorkoutSettings` | `WorkoutSettingsPresenter.exerciseAutoNext` | `WorkoutTrackerPresenter.advanceAfterExerciseCompletion(exerciseIndex:in:)` | live |
| `keepAlive` | `WorkoutSettings` | `WorkoutSettingsPresenter.keepAlive` | `WorkoutTrackerPresenter` (sets `isIdleTimerDisabled`) | live |
| `showWorkoutTimer` | `WorkoutSettings` | `WorkoutSettingsPresenter.showWorkoutTimer` | `WorkoutTrackerPresenter.showWorkoutTimer` | live |
| `showBodyweightContribution` | `WorkoutSettings` | `WorkoutSettingsPresenter.showBodyweightContribution` | `WorkoutTrackerPresenter` | live |
| `addSmartWarmUps` | `WorkoutSettings` | `WorkoutSettingsPresenter.addSmartWarmUps` | `WorkoutTrackerPresenter` (warm-up seeding guard) | live |
| `supersetAutoScroll` | `WorkoutSettings` | `WorkoutSettingsPresenter.supersetAutoScroll` | `WorkoutTrackerPresenter.advanceWithinSuperset(exerciseIndex:in:)` | live — **wired**. Not at `advanceAfterExerciseCompletion` as the audit guessed: the toggle says *after set completion*, which is the round-robin step between two members, not finishing an exercise. New rule in `WorkoutTrackerPresenter+Superset`. **Default `true`, so this changes behaviour for every existing user** — a release note, not a silent improvement. |
| **`previousWorkoutReference`** | `WorkoutSettings` | `PrevWORefSettingsPresenter.previousWorkoutReference` | **nothing** — only its own screen | `wire` — `WorkoutTrackerPresenter.loadPreviousWorkoutSession()`, which calls `getLastCompletedSessionForTemplate(templateId:authorId:)` unconditionally. `.workoutsInProgram` means filtering that lookup by `trainingProgramId`. |
| **`smartProgressionApplyInSession`** | `WorkoutSettings` | `SmartProgressionSettingsPresenter.applyInSession` | **nothing** | `decide` — there is no smart-progression engine in the app; the whole feature is three settings and a screen. |
| **`smartProgressionInitialLogFill`** | `WorkoutSettings` | `SmartProgressionSettingsPresenter.initialLogFill` | **nothing** | `decide` — sets are prefilled unconditionally in `WorkoutSessionModel.init(template:…)`, which has no notion of the three options. |
| **`smartProgressionAdjustmentMode`** | `WorkoutSettings` | `SmartProgressionSettingsPresenter.adjustmentMode` | **nothing** | `decide` — nothing applies progression, so weight-first vs reps-first has nothing to choose between. |
| `useRestTimers` | `WorkoutSettings` | `RestTimerSettingsPresenter.useRestTimers` | `SetTrackerRowPresenter` (set-completion handler) | live |
| `restAfterLastWarmUp` | `WorkoutSettings` | `RestTimerSettingsPresenter.restAfterLastWarmUp` | `SetTrackerRowPresenter.restAfterCompleting(_:in:)` | live |
| `restBetweenExercises` | `WorkoutSettings` | `RestTimerSettingsPresenter.restBetweenExercises` | `SetTrackerRowPresenter.restAfterCompleting(_:in:)` | live |
| `restBetweenSideSets` | `WorkoutSettings` | `RestTimerSettingsPresenter.restBetweenSideSets` | `SetTrackerRowPresenter.restAfterCompleting(_:in:)` | live |
| `warmUpRestScaling` | `WorkoutSettings` | `RestTimerSettingsPresenter.warmUpRestScaling` | `SetTrackerRowPresenter.restAfterCompleting(_:in:)` | live |
| `betweenExercisesRestScaling` | `WorkoutSettings` | `RestTimerSettingsPresenter.betweenExercisesRestScaling` | `SetTrackerRowPresenter.restAfterCompleting(_:in:)` | live |
| `sideSetRestScaling` | `WorkoutSettings` | `RestTimerSettingsPresenter.sideSetRestScaling` | `SetTrackerRowPresenter.restAfterCompleting(_:in:)` | live |
| **`restTimerPlaySound`** | `WorkoutSettings` | `RestTimerSettingsPresenter.restTimerPlaySound` | **nothing** | `wire` — `HKWorkoutManager.startRest(durationSeconds:session:currentExerciseIndex:)`, the one place a rest is started and therefore the one place its end can be announced. |
| **`restTimerVibrate`** | `WorkoutSettings` | `RestTimerSettingsPresenter.restTimerVibrate` | **nothing** | `wire` — same place as `restTimerPlaySound`. |
| `restDurationsByExerciseType` | `WorkoutSettings` | `TimerDurationPresenter.saveEdit()` | `SetTrackerRowPresenter.baseRestDuration(for:)` | live |
| `defaultRestDurationSeconds` | `WorkoutSettings` | `RestTimerSettingsPresenter` | `SetTrackerRowPresenter.baseRestDuration(for:)`, `WorkoutTrackerPresenter.restDurationSeconds`, `WorkoutRestTimerIntents` | live |

## Exercise Settings (per exercise)

`DialedIn/Managers/Training/Exercise/ExerciseSettings/Models/ExerciseSettingsModel.swift` — one
document per exercise template.

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| `note` | `ExerciseSettingsModel` | `ExerciseSettingsPresenter.onNotePressed()` | `ExerciseTrackerPresenter.note(for:)` → the card header | live — **wired**. No note is still no note, so a user who never wrote one sees the header unchanged. |
| **`restDurationOverride`** | `ExerciseSettingsModel` | `ExerciseSettingsPresenter.onRestTimerPressed()` **and** `TimerDurationPresenter.saveExerciseEdit()` | **nothing** — both screens only read back their own writes | `wire` — `SetTrackerRowPresenter.baseRestDuration(for:)`, which today falls straight from the per-type override to the global default and never consults the per-exercise one. This is the setting with the most obvious missing line in the app. |

## Food Log Settings

`DialedIn/Managers/Nutrition/FoodLogSettings/Models/FoodLogSettings.swift` — document
`food_log_settings`. Seven screens write it.

### Food Log Settings (the parent screen)

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| **`showOverages`** | `FoodLogSettings` | `FoodLogSettingsPresenter.showOverages` | **nothing** | `wire` — `MacroHeader` / `LoggerBannerPresenter`, which draw the rings that would show an overage. |
| `showsFoodTimestamps` | `FoodLogSettings` | `FoodLogSettingsPresenter.showsFoodTimestamps` | `NutritionPresenter.showsFoodTimestamps` → `MealItemRowStyle` | live |
| `showHourlyMacroTotals` | `FoodLogSettings` | `FoodLogSettingsPresenter.showHourlyMacroTotals` | `MealHourHeaderPresenter.showHourlyMacroTotals` | live |
| `showCalendarWeekBanner` | `FoodLogSettings` | `FoodLogSettingsPresenter.showCalendarWeekBanner` | `NutritionPresenter` → `NutritionView` | live |
| **`premove`** | `FoodLogSettings` | `FoodLogSettingsPresenter.premove` | **nothing** | `decide` — the name says nothing about what it should do, and no code or comment explains it. Needs the product owner before it can be either wired or dropped. |
| `timestampSide` | `FoodLogSettings` | `FoodLogSettingsPresenter.timestampSide` | `NutritionPresenter.timestampSide` → `MealItemRowStyle` | live |
| `showAddFoodsButton` | `FoodLogSettings` | `FoodLogSettingsPresenter.showAddFoodsButton` | `MealHourHeaderPresenter.showAddFoodsButton` | live |
| `startHour` | `FoodLogSettings` | `FoodLogSettingsPresenter.startHour` | `NutritionPresenter` (timeline range) | live |
| `endHour` | `FoodLogSettings` | `FoodLogSettingsPresenter.endHour` | `NutritionPresenter` (timeline range) | live |
| `showBrandedFoods` | `FoodLogSettings` | `FoodLogSettingsPresenter.showBrandedFoods` | `FoodItemSearchPresenter`, `IngredientListBuilderPresenter` | live |
| `showOpenFoodFactsFoods` | `FoodLogSettings` | `FoodLogSettingsPresenter.showOpenFoodFactsFoods` | `FoodItemSearchPresenter` | live |

### Timeline Actions (nutrition tab)

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| `hideFoodDetails` | `FoodLogSettings` | `TimelineActionsPresenter.hideFoodDetails` | `NutritionPresenter` | live |
| `hideEmptyHours` | `FoodLogSettings` | `TimelineActionsPresenter.hideEmptyHours` | `NutritionPresenter` | live |

### Timeline Food Tiles

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| `showFoodImageInTimeline` | `FoodLogSettings` | `TimelineFoodTilesPresenter` | `NutritionPresenter` | live |
| `showCaloriesInTimeline` | `FoodLogSettings` | `TimelineFoodTilesPresenter` | `NutritionPresenter` | live |
| `showMacrosInTimeline` | `FoodLogSettings` | `TimelineFoodTilesPresenter` | `NutritionPresenter` | live |

### Logger Food Tiles

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| `showFoodImageInLogger` | `FoodLogSettings` | `LoggerFoodTilesPresenter` | `IngredientListBuilderPresenter`, `RecipeListBuilderPresenter` | live |
| `showCaloriesInLogger` | `FoodLogSettings` | `LoggerFoodTilesPresenter` | `IngredientListBuilderPresenter`, `RecipeListBuilderPresenter` | live |
| `showMacrosInLogger` | `FoodLogSettings` | `LoggerFoodTilesPresenter` | `IngredientListBuilderPresenter`, `RecipeListBuilderPresenter` | live |
| `showPortionInLogger` | `FoodLogSettings` | `LoggerFoodTilesPresenter` | `IngredientListBuilderPresenter`, `RecipeListBuilderPresenter` | live |

### Logger Banner

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| `showCaloriesRing` | `FoodLogSettings` | `LoggerBannerPresenter` | `NutritionPresenter` → `MacroHeader` | live |
| `showProteinRing` | `FoodLogSettings` | `LoggerBannerPresenter` | `NutritionPresenter` → `MacroHeader` | live |
| `showFatRing` | `FoodLogSettings` | `LoggerBannerPresenter` | `NutritionPresenter` → `MacroHeader` | live |
| `showCarbsRing` | `FoodLogSettings` | `LoggerBannerPresenter` | `NutritionPresenter` → `MacroHeader` | live |

### Time Selection

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| `autoSetCurrentTime` | `FoodLogSettings` | `TimeSelectionPresenter.autoSetCurrentTime` | `MealHourHeaderPresenter.mealTime(for:)` | live — **wired**. A timeline row is the start of its hour, so the `+` on it filed a meal at 13:00 when tapped at 13:42. On, the exact time is used instead. Only for a row on today: "now" is not inside a past day, and presetting it there would move the meal rather than sharpen it. Default `false`, so nothing changes for an existing user. |

### Favourite Measurements — **wholly inert**

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| **`favouriteMeasurements`** | `FoodLogSettings` | `FavouriteMeasurementsPresenter.toggleMeasurement(_:)` | **nothing** | `wire` — the serving-unit picker in the food logger, where the chosen units would sort to the top. Nothing reads the list today, so the screen's only effect is on itself. |

### Favourites (written from the nutrition tab, not a settings screen)

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| `favouriteFoodIds` | `FoodLogSettings` | `CoreInteractor.setFavouriteFood(id:isFavourite:)` | `FoodLibraryPresenter` | live |
| `favouriteRecipeIds` | `FoodLogSettings` | `CoreInteractor.setFavouriteRecipe(id:isFavourite:)` | `FoodLibraryPresenter` | live |

### Optimisation

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| `quickAddEnabled` | `FoodLogSettings` | `OptimisationPresenter.quickAddEnabled` | `NutritionLibraryPickerPresenter.navToIngredientAmount(_:onPick:)`, `FoodLibraryPresenter.onFavouriteFoodPressed(_:onPick:)` | live — **wired**. The audit read this as needing a quick-add feature built. It did not: the toggle's own subtitle says "use default portion and skip the amount entry screen", and both halves already existed — `FoodModel.portionGramsCalculated` / `portionMillilitersCalculated` for the portion, and the item construction in `IngredientAmountPresenter.add`, now shared as `FoodModel.mealItem(amount:)`. Default `false`, so the amount step still shows for everyone who has not asked otherwise. |

## Nutrition Strategy Settings

`DialedIn/Managers/Nutrition/NutritionStrategySettings/Models/NutritionStrategySettings.swift` —
document `nutrition_strategy_settings`. Two screens write it.

### Strategy Settings — inert

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| **`checkInWeekday`** | `NutritionStrategySettings` | `StrategySettingsPresenter.checkInWeekday` | **nothing** | `decide` — no weekly check-in exists to happen on that day. |
| **`fastCheckIn`** | `NutritionStrategySettings` | `StrategySettingsPresenter.fastCheckInEnabled` | **nothing** | `decide` — same; there is no check-in to make fast. |
| **`partialLoggingEnabled`** | `NutritionStrategySettings` | `StrategySettingsPresenter.partialLoggingEnabled` | **nothing** | `decide` |
| **`weighInEnabled`** | `NutritionStrategySettings` | `StrategySettingsPresenter.weighInEnabled` | **nothing** | `decide` |
| **`fastingEnabled`** | `NutritionStrategySettings` | `StrategySettingsPresenter.fastingEnabled` | **nothing** | `decide` |
| **`loggingBreakEnabled`** | `NutritionStrategySettings` | `StrategySettingsPresenter.loggingBreakEnabled` | **nothing** | `decide` |

### Expenditure Settings — inert but for one field

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| `bmrEquation` | `NutritionStrategySettings` | `ExpenditureSettingsPresenter.bmrEquation` | `NutritionManager` (BMR calculation) | live |
| **`estimationMethod`** | `NutritionStrategySettings` | `ExpenditureSettingsPresenter.estimationMethod` | **nothing** | `wire` — `NutritionManager`'s BMR call, which already branches on `bmrEquation` and is where a body-fat-aware estimate would pick Katch-McArdle inputs. |
| **`calculationStartDate`** | `NutritionStrategySettings` | `ExpenditureSettingsPresenter.calculationStartDate` | **nothing** | `decide` — expenditure is a single static figure; there is no window for a start date to bound. |
| **`calculationMode`** | `NutritionStrategySettings` | `ExpenditureSettingsPresenter.calculationMode` | **nothing** | `decide` — the model's own comment says an adaptive engine is unwritten work. Dynamic vs fixed has nothing to switch between. |
| **`algorithmVersion`** | `NutritionStrategySettings` | `ExpenditureSettingsPresenter.algorithmVersion` | **nothing** | `remove` — one case, `v1`, so the control cannot change anything even once an engine exists. |
| **`stepInformedUpdates`** | `NutritionStrategySettings` | `ExpenditureSettingsPresenter.stepInformedUpdates` | **nothing** | `decide` — `StepsManager` has the data, but nothing feeds it into expenditure. |
| **`predictiveGoalAdjustments`** | `NutritionStrategySettings` | `ExpenditureSettingsPresenter.predictiveGoalAdjustments` | **nothing** | `decide` |

## Analytics Settings

`DialedIn/Managers/Analytics/AnalyticsSettings/Models/AnalyticsSettings.swift` — document
`analytics_settings`.

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| `hiddenSectionIds` | `AnalyticsSettings` | `CustomiseAnalyticsPresenter.setVisible(_:for:)` | `AnalyticsPresenter.isVisible(_:)` → `AnalyticsView` | live |

## Shortcut Settings

`DialedIn/Managers/Shortcuts/Models/ShortcutSettings.swift` — document `shortcut_settings`.

| Setting | Defined in | Written by | Read by | Verdict |
|---|---|---|---|---|
| `quickActionIds` | `ShortcutSettings` | `ShortcutsPresenter.apply(_:event:)` | `SearchPresenter.quickActions` → `SearchView` | live |

---

## Bugs found and fixed alongside this audit

These are defects regardless of which way the wire-or-remove decision goes, so they were fixed here
rather than left with the audit.

1. **Two screens disagreed on what an empty rest picker means.**
   `ExerciseSettingsPresenter.onRestTimerPressed()` treats 0:00 as "clear the override" and stores
   `nil`; `TimerDurationPresenter.saveExerciseEdit()` stored a literal zero-second override, which
   then showed in the override list as a row reading "0:00". `TimerDurationPresenter` now clears on
   zero, matching the other screen.

2. **Eleven settings screens wrote a stale copy of their document.**
   Each holds a snapshot of the whole settings document taken at `init` and saves the whole thing
   back, so a copy that was never refreshed reverts whatever another screen saved in the meantime.
   Five workout-settings screens had already been fixed by re-reading in `onViewAppear`; the same
   shape remained in:
   - `FoodLogSettings` (seven writers): `TimelineFoodTilesPresenter`, `LoggerFoodTilesPresenter`,
     `LoggerBannerPresenter`, `TimeSelectionPresenter`, `FavouriteMeasurementsPresenter`,
     `OptimisationPresenter`, `TimelineActionsPresenter`. This one also loses the user's favourite
     foods and recipes, which live in the same document and are written from the nutrition tab.
   - `NutritionStrategySettings` (two writers): `StrategySettingsPresenter`,
     `ExpenditureSettingsPresenter` — each reverts the other.
   - `AnalyticsSettings` and `ShortcutSettings` have one writer each, so no sibling screen can
     revert them, but a change arriving from another device while the screen sits open still can.
     `CustomiseAnalyticsPresenter` and `ShortcutsPresenter` were given the same re-read.

## If told to wire only a few

In order:

1. **`ExerciseSettingsModel.restDurationOverride`** — two screens already collect it and a third
   already resolves rest durations. `SetTrackerRowPresenter.baseRestDuration(for:)` is one `if` away
   from honouring it, and a per-exercise rest is the most concrete promise on this list.
2. **`restTimerPlaySound` / `restTimerVibrate`** — the rest timer is live and heavily used; these
   two are the difference between noticing a rest ending and not. Both land in the same place.
3. **`previousWorkoutReference`** — the lookup it should filter already exists and already has the
   `trainingProgramId` it would filter on.
4. **`autoSetCurrentTime`** — it is a whole screen's only control, and the food logger already has
   the time field it would preset.
