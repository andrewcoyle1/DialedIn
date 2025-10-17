# App Group Setup for Live Activity Timer Buttons

## Problem
The Live Activity timer buttons were triggering intents successfully, but the rest timer wasn't actually changing. This was because the widget extension was updating the Live Activity, but the main app's `HKWorkoutManager` was overwriting those changes every second with its own `restEndTime` value.

## Solution
Implemented **App Groups** to share data between the main app and widget extension. Now both targets can read and write to shared storage, keeping them in sync.

## What Was Implemented

### 1. Shared Storage Helper
**File**: `Shared/SharedWorkoutStorage.swift`
- Provides a simple API for reading/writing rest end time
- Uses App Group UserDefaults (`group.com.dialedin.app`)

### 2. Updated Intents
**File**: `DialedIn/Services/Training/WorkoutRestTimerIntents.swift`
- `AdjustRestTimerIntent`: Now writes to shared storage when adjusting timer
- `SkipRestTimerIntent`: Now clears shared storage when skipping

### 3. Updated HKWorkoutManager
**File**: `DialedIn/Services/HealthKitManager/HKWorkoutManager.swift`
- Added `syncRestEndTimeFromSharedStorage()`: Reads from shared storage every second
- Updated `startRest()`: Writes to shared storage when starting rest
- Updated `cancelRest()`: Clears shared storage when canceling rest
- Updated `endRest()`: Clears shared storage when rest ends

### 4. Entitlements Files Updated
- `DialedIn/DialedIn.entitlements`
- `DialedIn/DialedIn-Debug.entitlements`
- `WorkoutSessionActivity/WorkoutSessionActivity.entitlements` (new)

All now include the App Group: `group.com.dialedin.app`

### 5. Constants Updated
**File**: `DialedIn/Utilities/Constants.swift`
- Added `appGroupIdentifier = "group.com.dialedin.app"`

## Required Xcode Configuration

⚠️ **IMPORTANT**: You need to enable App Groups in Xcode for both targets:

### For Main App Target (DialedIn)
1. Open project settings in Xcode
2. Select the **DialedIn** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **App Groups**
6. Enable the checkbox for `group.com.dialedin.app`

### For Widget Extension Target (WorkoutSessionActivity)
1. Select the **WorkoutSessionActivity** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Enable the checkbox for `group.com.dialedin.app`

### For Developer Portal (if needed)
If Xcode shows errors about App Groups not being available:
1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to Certificates, Identifiers & Profiles
3. Select your App ID
4. Enable **App Groups** capability
5. Select or create the App Group: `group.com.dialedin.app`
6. Do the same for the Widget Extension App ID

## How It Works Now

1. **User taps +15s button in Live Activity**
   - Intent updates Live Activity `restEndsAt` (+15 seconds)
   - Intent writes new time to shared storage

2. **Main app syncs the change**
   - `HKWorkoutManager` timer runs every second
   - Calls `syncRestEndTimeFromSharedStorage()`
   - Detects the change (>0.5s difference)
   - Updates its own `restEndTime`
   - Reschedules the rest end timer

3. **Live Activity stays in sync**
   - Main app updates Live Activity with synced time
   - User sees the adjusted timer
   - Timer continues with new end time

## Testing
After configuring the App Groups in Xcode:
1. Start a workout session
2. Complete a set to trigger rest timer
3. Tap the **+15s** button in the Live Activity
4. Rest timer should increase by 15 seconds
5. Tap the **-15s** button
6. Rest timer should decrease by 15 seconds
7. Tap **Skip**
8. Rest timer should end immediately

The changes should persist and not get overwritten!

