# Adaptive expenditure — algorithm spec (v1)

Status: specification for implementation. Written 2026-09-22. Companion to
`docs/dead-settings-audit.md`, which lists the eleven settings this engine gives meaning to.

## 1. Purpose

Replace the one-shot formula TDEE (`NutritionManager.estimateTDEE`) with an estimate that adapts
to what the user actually logs: daily energy intake from meal logs and the trend in scale weight.
The formula stays as the **prior** — the estimate before there is enough data, and the anchor that
bounds the adaptive figure. Nothing in this spec deletes or bypasses the existing formula code.

The engine is **pure**: a value-type `ExpenditureEngine` in
`DialedIn/Managers/Nutrition/Expenditure/` that takes daily samples and settings and returns a
per-day estimate history. It has no manager dependencies, no `@MainActor`, no `Date()` calls
(the caller passes "today"), and is exhaustively unit-testable. `CoreInteractor` gathers the
samples from the managers and feeds the engine.

## 2. Inputs

### 2.1 Daily samples

One `DailySample` per calendar day in the user's current calendar/timezone, from the first day
with any data up to and including **yesterday**. Today is never included: it is incomplete.

```
struct DailySample {
    let day: Date            // start of day
    let intakeKcal: Double?  // nil when the day has no meal logs
    let weightKg: Double?    // nil when no weigh-in that day
    let steps: Int?          // nil when no steps record
}
```

- `intakeKcal` = sum of `MealLogModel.totalCalories` over all meal logs whose `dayKey` is that
  day. A day with one or more meal logs but zero total calories counts as **logged with 0 kcal**,
  not as unlogged; a day with no meal logs is `nil`.
- `weightKg` = mean of `BodyMeasurementEntry.weightKg` over entries on that day with
  `weightKg != nil` and `deletedAt == nil`. Multiple weigh-ins in a day are averaged.
- `steps` = `StepsModel.number` for that day, ignoring records with `deletedAt != nil`. If more
  than one record exists for a day, take the largest.

### 2.2 Settings (from `NutritionStrategySettings`)

| Setting | Meaning in this engine |
|---|---|
| `calculationMode` | `.dynamic`: run the algorithm. `.fixed`: every day's estimate is the prior; the engine still returns a history so the chart draws a flat line, and `isProvisional` is `false` with `source = .fixed`. |
| `calculationStartDate` | Samples strictly before this day are discarded before anything else runs. The replay starts fresh (prior only) from this day. `nil` means use all samples. |
| `algorithmVersion` | `.version1` selects this algorithm. There is no other version; the engine `switch`es on it so a v2 has an obvious home. |
| `stepInformedUpdates` | Enables the step nowcast in §3.6. |
| `predictiveGoalAdjustments` | Only affects the **proposal** in §4, not the estimate. |
| `estimationMethod`, `bmrEquation` | Already live; they shape the **prior** through the existing `resolvedBMREquation` path. The engine takes the prior as a number and does not know about them. |

### 2.3 Other inputs

- `priorKcal: Double` — the formula TDEE for this user, computed by the existing code path.
- `today: Date` — the day the estimate is for. Samples must end the day before.
- `calendar: Calendar`.

## 3. Algorithm (version 1)

Constants, all in one `ExpenditureEngine.Constants` namespace so tests and a future v2 can see them:

| Name | Value | Why |
|---|---|---|
| `kcalPerKg` | 7700 | Energy content of a kilogram of body-mass change; the conventional figure. |
| `trendAlpha` | 0.10 | EMA smoothing for scale weight; ≈10-day time constant. |
| `outlierFraction` | 0.025 | A weigh-in more than 2.5 % from the trend is clamped to that band before it updates the trend. |
| `windowDays` | 28 | The energy-balance regression window. |
| `minWindowDays` | 14 | Fewer days than this since the first sample → provisional. |
| `minLoggedFraction` | 0.5 | Fewer logged days than half the window → provisional. |
| `minWeighIns` | 4 | Fewer weigh-ins in the window → provisional. |
| `minWeighInSpanDays` | 7 | First and last weigh-in in the window closer than this → provisional. |
| `blendAlpha` | 0.30 | Daily blend of the raw estimate into the running estimate. |
| `maxDailyStepKcal` | 150 | The running estimate never moves more than this per day. |
| `priorBoundLow` / `priorBoundHigh` | 0.60 / 1.60 | The estimate is clamped to this band around the prior; guards against garbage logging. |
| `kcalPerStepPerKg` | 0.0005 | Step nowcast: kcal per step per kg of body weight (≈35 kcal per 1000 steps at 70 kg). |
| `maxStepNowcastKcal` | 300 | Cap on the step nowcast in either direction. |

### 3.1 Trend weight

Replay day by day over the (start-date-filtered) samples:

1. Seed: the trend on the first day with a weigh-in is the mean of the weigh-ins in the first
   seven days that have any (so a single first reading does not anchor everything).
2. For each later day with a weigh-in `w`: let `t` be the current trend. Clamp `w` to
   `[t·(1−outlierFraction), t·(1+outlierFraction)]`, then `t ← t + trendAlpha·(w_clamped − t)`.
3. Days without a weigh-in leave the trend unchanged (carried forward), and are recorded as
   `trendWeightKg` for that day so the chart has a value.
4. Before the first weigh-in `trendWeightKg` is `nil`.

### 3.2 Window

For the estimate on day **D** (each day of the replay, and finally `today`), the window is the
`windowDays` days ending the day before D, intersected with the available samples.

Sufficiency — the window is **sufficient** when all hold:
- days from the first sample (after start-date filtering) to D−1 ≥ `minWindowDays`;
- logged days in the window ≥ `minLoggedFraction` × (days present in the window);
- weigh-ins in the window ≥ `minWeighIns`;
- last weigh-in day − first weigh-in day in the window ≥ `minWeighInSpanDays`.

If insufficient, the day's estimate is the running estimate carried forward (initially the
prior) and `isProvisional = true`.

### 3.3 Raw energy balance

When sufficient:

```
meanIntake     = mean(intakeKcal over logged days in window)
deltaTrendKg   = trend(last day of window) − trend(first day of window that has a trend)
spanDays       = number of days between those two trend readings
dailySurplus   = deltaTrendKg · kcalPerKg / spanDays
rawExpenditure = meanIntake − dailySurplus
```

Unlogged days are assumed to look like the logged days' mean; that is what the
`minLoggedFraction` guard is for. Do not attempt to impute them any other way in v1.

### 3.4 Running estimate

```
running ← running + clamp(blendAlpha · (rawExpenditure − running), −maxDailyStepKcal, +maxDailyStepKcal)
running ← clamp(running, prior · priorBoundLow, prior · priorBoundHigh)
```

`running` starts at `priorKcal`. This is applied once per replay day. The blend, not the raw
figure, is what the user sees, so one bad week moves the number slowly and reversibly.

### 3.5 Fixed mode

`calculationMode == .fixed`: skip §3.2–3.4; every day's `kcal = priorKcal`,
`source = .fixed`, `isProvisional = false`. Trend weight (§3.1) is still computed so the chart
and the goal screens keep their trend line.

### 3.6 Step nowcast (optional)

Only when `stepInformedUpdates` is on **and** steps exist for at least half the window days
**and** the window is sufficient:

```
recentSteps  = mean(steps over the last 7 days that have steps)
windowSteps  = mean(steps over the window days that have steps)   // all of them, the last 7 included
nowcast      = clamp((recentSteps − windowSteps) · kcalPerStepPerKg · trendWeightKg, −maxStepNowcastKcal, +maxStepNowcastKcal)
kcal         = running + nowcast
```

The nowcast is additive on top of the running estimate for **display and proposals only**; it is
not fed back into `running`. The reason: the energy balance already captures steps over the
window; the nowcast only anticipates a change in the last week that the 28-day window has not
yet absorbed. `ExpenditureEstimate.stepAdjustmentKcal` carries it so the UI can show it.

### 3.7 Output

```
struct ExpenditureEstimate: Equatable {
    let day: Date
    let kcal: Double                 // what the app uses; rounded to the nearest 1 kcal
    let source: Source               // .prior, .adaptive, .fixed
    let isProvisional: Bool          // true while the window is insufficient
    let trendWeightKg: Double?
    let weeklyTrendChangeKg: Double? // deltaTrendKg · 7 / spanDays over the window; nil when provisional
    let loggedDays: Int
    let weighInCount: Int
    let windowDays: Int
    let stepAdjustmentKcal: Double   // 0 unless the nowcast applied
}

struct ExpenditureEngine {
    func history(samples: [DailySample], priorKcal: Double, settings: NutritionStrategySettings,
                 today: Date, calendar: Calendar) -> [ExpenditureEstimate]   // one per replay day, ascending, last is `today`
    func current(...) -> ExpenditureEstimate                                 // history(...).last
}
```

The history is recomputed from scratch on every call. It is deterministic given the inputs, so
nothing about the estimate is persisted. This keeps the engine free of a migration story; the
cost is O(days × window) per call, which is fine for years of data.

## 4. Proposal (propose-and-confirm, per product decision)

The estimate **never** silently rewrites `DietPlan`. Instead `CoreInteractor` exposes a
`targetProposal: TargetProposal?`:

```
struct TargetProposal: Equatable {
    let expenditureKcal: Double
    let currentTargetKcal: Double     // mean of the current plan's 7 days
    let proposedTargetKcal: Double
    let weeklyTrendChangeKg: Double?
    let goalWeeklyChangeKg: Double?
    let reason: Reason                // .expenditureMoved, .rateOffTarget
}
```

Rules:
- Nil when there is no current diet plan, when the estimate is provisional, or when
  `calculationMode == .fixed`.
- `proposedTargetKcal = expenditureKcal + goalWeeklyChangeKg · kcalPerKg / 7` where
  `goalWeeklyChangeKg` comes from `GoalManager.currentGoal` with `status == .active`
  (`weeklyChangeKg` is negative for loss). With no active goal it is `expenditureKcal`
  (maintenance).
- When `predictiveGoalAdjustments` is on and there is an active goal and `weeklyTrendChangeKg`
  is available: add `correction = clamp((goalWeeklyChangeKg − weeklyTrendChangeKg) · kcalPerKg / 7, −200, +200)`.
  This nudges the target when the observed rate is off the goal rate even if expenditure looks
  right. When off, no correction.
- Apply the plan's calorie floor: `proposedTargetKcal = max(proposed, plan.calorieFloor.minimumValue)`.
- Nil when `|proposedTargetKcal − currentTargetKcal| < 50`. A proposal must be worth a tap.

Accepting a proposal calls the existing `computeDietPlan` with the new expenditure in place of
the formula figure (see §5) and saves the plan. Dismissing records the dismissed value in
`UserDefaults` under `dismissedTargetProposalKcal`, and the proposal stays hidden until the
proposed target differs from the dismissed one by ≥ 50 kcal. The weekly check-in cadence
(`checkInWeekday`, `fastCheckIn`, and friends) is a separate piece of work and is not part of
this spec; for now the proposal is visible whenever it is non-nil.

## 5. Integration points

1. `NutritionManager.computeDietPlan(user:delegate:trainingProgram:expenditureKcal:)` gains an
   optional `expenditureKcal: Double? = nil`; when non-nil it replaces `estimateTDEE(user:)` for
   the target calculation and is what lands in `DietPlan.tdeeEstimate`.
2. `CoreInteractor`:
   - `var expenditureHistory: [ExpenditureEstimate]` — built from `mealLogs`,
     `bodyMeasurements`, `stepsHistory`, `nutritionStrategySettings`, the existing
     `estimateTDEE(user:)` prior, and `Date()` as today.
   - `var currentExpenditure: ExpenditureEstimate`.
   - `var targetProposal: TargetProposal?`.
   - `func acceptTargetProposal() async throws` and `func dismissTargetProposal()`.
3. Expenditure Settings screen: show `currentExpenditure.kcal` with a one-line status
   ("Adaptive · 21 of 28 days logged", "Estimated from your profile until 14 days are logged",
   "Fixed"). Replace the flat expenditure chart figure with `expenditureHistory` so the chart
   moves. Keep every existing control.
4. Nutrition overview: a dismissible "New targets suggested" card driven by `targetProposal` with
   Accept and Not now. Minimal; the check-in flow will restyle it later.
5. `DietPlan` needs no schema change.

## 6. Test cases (unit, `DialedInUnitTests/Managers/Nutrition/ExpenditureEngineTests.swift`)

Build samples with a helper `days(_ n: Int, intake: (Int) -> Double?, weight: (Int) -> Double?, steps: (Int) -> Int? = { _ in nil })`. Prior 2500 unless stated. Use a fixed `Calendar(identifier: .gregorian)` with UTC and a fixed `today`.

1. **No samples** → one estimate, `kcal == prior`, `.prior`, provisional.
2. **Thirteen days of perfect data** → still provisional (below `minWindowDays`).
3. **Maintenance**: 60 days, intake 2400 every day, weight flat at 80 → after day 14 the
   estimate converges toward 2400; on the last day `abs(kcal − 2400) < 15`, `.adaptive`,
   not provisional, `weeklyTrendChangeKg ≈ 0`.
4. **Deficit**: 60 days, intake 2000, weight falling linearly 0.5 kg/week from 80 →
   converges toward 2000 + 550 = 2550 (±40 by the last day).
5. **Surplus** mirror of 4.
6. **Sparse logging**: 28 days, only 10 logged → provisional. 15 logged → adaptive.
7. **Weigh-in span**: 28 days, all logged, weigh-ins only on days 20–27 (span 7) → adaptive;
   weigh-ins only on days 24–27 → provisional.
8. **Outlier**: as case 3, but one weigh-in of 95 on day 40 → the trend on day 40 moves by
   less than 0.25 kg, and the last-day estimate is still within 20 of 2400.
9. **Prior bound**: intake logged as 200 every day, weight flat → estimate never goes below
   `0.6 · prior`.
10. **Daily step cap**: raw estimate 1000 above running → running moves exactly 150 on the
    first sufficient day.
11. **Start date**: case 4 data, but `calculationStartDate` set to day 50 → the estimate on
    the last day is provisional (only 10 days after the start).
12. **Fixed mode** → every day's `kcal == prior`, `.fixed`, not provisional, trend still populated.
13. **Step nowcast on**: case 3 plus steps 8000 for the earlier window days and 12000 for the
    last 7, weight 80 → `stepAdjustmentKcal = 3000 · 0.0005 · 80 = 120`, and `kcal` includes it.
    Off → 0. `windowSteps` in §3.6 is the mean over **all** the window's days, the trailing week
    included, so the baseline here is (21 · 8000 + 7 · 12000) / 28 = 9000 rather than 8000 — the
    recent week is compared against a window it is part of, which is what stops the nowcast
    double-counting a change the energy balance has already absorbed.
14. **Today excluded**: a sample dated `today` must be ignored (assert via a huge intake on
    today not moving the estimate).
15. **Determinism**: same inputs twice → identical arrays.

Proposal tests (`TargetProposalTests`): nil when provisional; nil under fixed; maintenance with
no goal → proposed == expenditure; loss goal −0.5 kg/wk → expenditure − 550; predictive
correction applied and clamped at ±200; below-50 delta → nil; floor respected; dismissal hides
until the value moves ≥ 50.

## 7. Out of scope for v1

Weekly check-in scheduling, partial-logging day exclusion, fasting-day handling, logging breaks
(all `NutritionStrategySettings` strategy fields), body-fat-driven lean-mass tracking, and any
persistence of estimates. Each of those consumes this engine's output; none changes it.
