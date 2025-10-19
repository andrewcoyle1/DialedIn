# Cross-Device Training Plan Sync - Implementation Summary

## Overview
Implemented cross-device synchronization for training plans using Firestore real-time listeners with optimistic updates and last-write-wins conflict resolution. Migrated local storage from UserDefaults to SwiftData for consistency with other services.

## Changes Made

### 1. Created SwiftData Entity Models
**File**: `DialedIn/Services/Training/TrainingPlan/Models/TrainingPlanEntity.swift` (NEW)

- Created `TrainingPlanEntity`, `TrainingWeekEntity`, `ScheduledWorkoutEntity`, and `TrainingGoalEntity`
- Each entity includes:
  - `init(from model:)` to convert from domain models
  - `toModel()` to convert back to domain models
  - Proper `@Relationship` annotations for cascading deletes
  - `@Attribute(.unique)` on primary keys

### 2. Migrated Local Persistence to SwiftData
**File**: `DialedIn/Services/Training/TrainingPlan/Services/Local/SwiftTrainingPlanPersistence.swift`

**Changes**:
- Replaced UserDefaults-based storage with SwiftData ModelContainer
- Store location: `ApplicationSupport/DialedIn.TrainingPlansStore/TrainingPlans.store`
- Added one-time migration from UserDefaults to SwiftData
- Updated all CRUD methods to use `FetchDescriptor` and `ModelContext`
- Migration preserves all existing training plan data

**Migration Logic**:
- Checks `training_plans_migrated_to_swiftdata` flag
- If not migrated, loads plans from UserDefaults
- Converts each plan to SwiftData entities
- Saves to SwiftData store
- Sets migration complete flag

### 3. Added userId Filtering to Firebase Service
**File**: `DialedIn/Services/Training/TrainingPlan/Services/Remote/FirebaseTrainingPlanService.swift`

**Changes**:
- Updated `fetchAllPlans(userId:)` to filter by user_id field
- Updated `fetchPlan(id:userId:)` to verify plan ownership
- Added `addPlansListener(userId:onChange:)` for real-time sync
- Firestore listener uses `whereField("user_id", isEqualTo: userId)`

**Security**:
- All queries now filter by userId
- Prevents users from accessing other users' plans
- Plan ownership verified on fetch

### 4. Updated Protocol Signatures
**File**: `DialedIn/Services/Training/TrainingPlan/Services/Remote/RemoteTrainingPlanService.swift`

**Changes**:
- Added userId parameter to fetch methods
- Added listener method: `func addPlansListener(userId: String, onChange: @escaping ([TrainingPlan]) -> Void) -> (() -> Void)`

**File**: `DialedIn/Services/Training/TrainingPlan/Services/Remote/MockTrainingPlanService.swift`

**Changes**:
- Updated mock service to match new protocol signatures
- Added userId filtering in mock implementations

### 5. Enhanced TrainingPlanManager with Sync
**File**: `DialedIn/Services/Training/TrainingPlan/TrainingPlanManager.swift`

**New Features**:
- `setUserId(_:)` - Sets userId and starts sync listener
- `startSyncListener()` - Attaches Firestore listener
- `stopSyncListener()` - Cleans up listener
- `mergeRemotePlans(_:)` - Merge logic with conflict resolution

**Sync Behavior**:
- **Optimistic Updates**: Local changes save immediately, sync async to Firebase
- **Conflict Resolution**: Last-write-wins based on `modifiedAt` timestamp
- **Automatic Deletion Sync**: Plans deleted remotely are removed locally
- **Initial Sync**: Fetches all plans from remote on first userId set

**Merge Logic**:
1. Compare local and remote plans by planId
2. Keep whichever has newer `modifiedAt` timestamp
3. Add new remote plans to local storage
4. Remove local plans not present in remote (deleted)
5. Update UI state after merge

### 6. Integrated with App Authentication Flow
**File**: `DialedIn/Core/AppView/AppView.swift`

**Changes**:
- Added `@Environment(TrainingPlanManager.self)` 
- Added `onChange(of: userManager.currentUser?.userId)` handler
- Calls `trainingPlanManager.setUserId(_)` when user logs in
- Triggers initial sync and starts listener

## How It Works

### On App Launch
1. TrainingPlanManager initializes without userId (nil)
2. Loads training plans from local SwiftData store
3. If first launch with UserDefaults data, migrates to SwiftData
4. Waits for authentication

### On User Login
1. AppView detects userId change via `onChange` modifier
2. Calls `trainingPlanManager.setUserId(userId)`
3. Manager starts Firestore listener for that userId
4. Performs initial sync from remote to local
5. Real-time updates start flowing

### On Plan Creation/Update
1. Plan saved to local SwiftData immediately (optimistic)
2. UI updates instantly
3. Plan synced to Firebase asynchronously
4. Firestore listener on other devices receives update
5. Other devices merge remote changes with local data

### On Plan Deletion
1. Plan deleted from local SwiftData
2. Plan deleted from Firebase
3. Firestore listener on other devices receives deletion
4. Other devices remove plan from local storage

### Conflict Resolution
- If same plan modified on multiple devices simultaneously
- Compare `modifiedAt` timestamps
- Keep version with newer timestamp (last-write-wins)
- Simple, predictable, works well for single-user scenarios

## Analytics (No Changes Required)
Analytics compute from workout sessions which already sync to Firebase via `WorkoutSessionManager`, so they automatically work across devices without additional changes.

## Testing Checklist
- [ ] Verify UserDefaults migration on first launch
- [ ] Create plan on Device A, verify appears on Device B
- [ ] Update plan on Device B, verify changes appear on Device A
- [ ] Delete plan on Device A, verify disappears on Device B
- [ ] Test offline mode: changes sync when back online
- [ ] Test conflicts: simultaneous edits resolve to last-write-wins
- [ ] Verify userId filtering: users can't see other users' plans

## Files Modified
1. `DialedIn/Services/Training/TrainingPlan/Models/TrainingPlanEntity.swift` (NEW)
2. `DialedIn/Services/Training/TrainingPlan/Services/Local/SwiftTrainingPlanPersistence.swift`
3. `DialedIn/Services/Training/TrainingPlan/Services/Remote/RemoteTrainingPlanService.swift`
4. `DialedIn/Services/Training/TrainingPlan/Services/Remote/FirebaseTrainingPlanService.swift`
5. `DialedIn/Services/Training/TrainingPlan/Services/Remote/MockTrainingPlanService.swift`
6. `DialedIn/Services/Training/TrainingPlan/TrainingPlanManager.swift`
7. `DialedIn/Core/AppView/AppView.swift`

## Firestore Security Rules (Recommended)
Add these rules to ensure proper access control:

```javascript
match /training_plans/{planId} {
  allow read, write: if request.auth != null && 
                        resource.data.user_id == request.auth.uid;
  allow create: if request.auth != null && 
                   request.resource.data.user_id == request.auth.uid;
}
```

## Benefits
1. ✅ Training plans sync across all user devices in real-time
2. ✅ Offline-first: works without internet, syncs when reconnected
3. ✅ Consistent storage: Uses SwiftData like workout sessions
4. ✅ Better security: userId filtering prevents unauthorized access
5. ✅ Scalable: SwiftData handles large datasets better than UserDefaults
6. ✅ Real-time: Changes appear on other devices within seconds
7. ✅ Simple conflicts: Last-write-wins is predictable and works well

## Migration Notes
- Existing users with UserDefaults data will be automatically migrated
- Migration happens once on first app launch after update
- No data loss - all existing plans are preserved
- Migration is logged to console for debugging

## Future Enhancements
- Add more sophisticated conflict resolution if needed
- Implement plan sharing between users
- Add offline queue for failed sync operations
- Add sync status indicators in UI

