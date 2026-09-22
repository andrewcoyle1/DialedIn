//
//  TestManagers.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 20/09/2026.
//

import Foundation
import Testing
@testable import DialedIn

/// Managers built the way `Dependencies` builds them for `.mock`, but with local persistence off.
///
/// Every manager now takes sync engines rather than a services struct, and a sync engine with
/// persistence on opens SwiftData storage keyed by its `managerKey` — shared between tests, and
/// left behind after them. Passing `enableLocalPersistence: false` keeps each test to the data it
/// was given.
@MainActor
enum TestManagers {

    /// A unique key per call, so two engines in the same run never read each other's storage even
    /// if persistence is switched on.
    static func key(_ name: String = "test") -> String {
        "\(name)-\(UUID().uuidString)"
    }

    static func collectionEngine<T: DataSyncModelProtocol>(
        _ collection: [T],
        key name: String = "collection"
    ) -> CollectionSyncEngine<T> {
        CollectionSyncEngine<T>(
            remote: MockRemoteCollectionService(collection: collection),
            managerKey: key(name),
            enableLocalPersistence: false
        )
    }

    static func documentEngine<T: DataSyncModelProtocol>(
        _ document: T?,
        key name: String = "document"
    ) -> DocumentSyncEngine<T> {
        DocumentSyncEngine<T>(
            remote: MockRemoteDocumentService(document: document),
            managerKey: key(name),
            enableLocalPersistence: false
        )
    }

    static func userManager(user: UserModel?, following: [UserModel] = []) -> UserManager {
        UserManager(
            queryService: MockUserQueryService(),
            userSyncEngine: documentEngine(user, key: "user"),
            followingUsersSyncEngine: collectionEngine(following, key: "following-users")
        )
    }

    /// Waits for `condition` to hold, polling until `timeout`. Returns whether it ever did.
    ///
    /// A sync engine applies a write when its listener next emits, which happens on its own task
    /// after the write returns — so `currentCollection` is not up to date the instant `saveDocument`
    /// does. Polling keeps that from being either a fixed sleep or a race.
    ///
    /// The timeout is generous because it only costs anything when a test is already failing: the
    /// wait returns the moment the condition holds. At three seconds a busy machine — several
    /// simulator clones running at once — timed thirty of these out in one run, every one of them
    /// a listener that had simply not emitted yet. Twenty seconds is the window the auto-dismiss
    /// test in `AppShellPresenterTests` already needed for the same reason.
    @discardableResult
    static func eventually(
        timeout: Duration = .seconds(20),
        _ condition: () -> Bool
    ) async -> Bool {
        let deadline = ContinuousClock.now.advanced(by: timeout)
        while ContinuousClock.now < deadline {
            if condition() { return true }
            try? await Task.sleep(for: .milliseconds(20))
        }
        return condition()
    }

    /// A `UserManager` already listening, so `currentUser` is `user`. Anything reading the signed-in
    /// user's preferences needs this rather than `userManager(user:)`, whose engine holds nothing
    /// until it starts listening.
    static func signedInUserManager(_ user: UserModel?) async throws -> UserManager {
        let manager = userManager(user: user)
        try await manager.signIn(auth: UserAuthInfo(uid: user?.userId ?? "test-user"), isNewUser: false)
        if user != nil {
            // Named here rather than left to whichever assertion reads `currentUser` next, so a
            // listener that never emitted does not look like a wrong value.
            let signedIn = await eventually { manager.currentUser != nil }
            if !signedIn {
                Issue.record("The user sync engine never emitted, so the manager has no user.")
            }
        }
        return manager
    }

    static func exerciseModelManager(
        user userExercises: [ExerciseModel] = [],
        system systemExercises: [ExerciseModel] = []
    ) -> ExerciseModelManager {
        ExerciseModelManager(
            userExerciseSyncEngine: collectionEngine(userExercises, key: "user-exercises"),
            systemExercisePersistence: MockLocalCollectionPersistence(collection: systemExercises)
        )
    }

    static func gymProfileManager(profiles: [GymProfileModel] = []) -> GymProfileManager {
        GymProfileManager(gymProfileSyncEngine: collectionEngine(profiles, key: "gym-profiles"))
    }

    static func workoutSessionManager(
        sessions: [WorkoutSessionModel] = [],
        following: [WorkoutSessionModel] = []
    ) -> WorkoutSessionManager {
        WorkoutSessionManager(
            likeService: MockWorkoutSessionLikeService(),
            activeWorkoutSessionPersistence: MockLocalDocumentPersistence<WorkoutSessionModel>(),
            userWorkoutSessionSyncEngine: collectionEngine(sessions, key: "workout-sessions"),
            followingWorkoutSessionSyncEngine: CollectionGroupSyncEngine<WorkoutSessionModel>(
                remote: MockRemoteCollectionGroupService(collection: following),
                managerKey: key("following-sessions"),
                enableLocalPersistence: false
            )
        )
    }

    /// A workout session manager already listening, so `workoutSessions` holds `sessions`.
    static func signedInWorkoutSessionManager(
        sessions: [WorkoutSessionModel]
    ) async -> WorkoutSessionManager {
        let manager = workoutSessionManager(sessions: sessions)
        await manager.signIn(userId: "author-1")
        await eventually { manager.workoutSessions.count == sessions.count }
        return manager
    }

    static func bodyMeasurementsManager(
        entries: [BodyMeasurementEntry] = []
    ) -> BodyMeasurementsManager {
        BodyMeasurementsManager(
            bodyMeasurementsSyncEngine: collectionEngine(entries, key: "body-measurements"),
            healthKitService: MockHealthKitWeightService()
        )
    }

    /// A body measurements manager already listening, so `bodyMeasurements` holds `entries`.
    static func signedInBodyMeasurementsManager(
        entries: [BodyMeasurementEntry]
    ) async -> BodyMeasurementsManager {
        let manager = bodyMeasurementsManager(entries: entries)
        await manager.signIn(userId: "author-1")
        await eventually { manager.bodyMeasurements.count == entries.count }
        return manager
    }

    static func mealLogManager(meals: [MealLogModel] = []) -> MealLogManager {
        MealLogManager(
            draftMealLogPersistence: MockLocalDocumentPersistence<MealLogModel>(),
            mealLogSyncEngine: collectionEngine(meals, key: "meal-logs")
        )
    }

    /// A meal log manager already listening, so `userMeals` holds `meals`.
    static func signedInMealLogManager(meals: [MealLogModel]) async -> MealLogManager {
        let manager = mealLogManager(meals: meals)
        await manager.signIn(userId: "author-1")
        await eventually { manager.userMeals.count == meals.count }
        return manager
    }

    #if canImport(HealthKit)
    static func stepsManager(
        entries: [StepsModel] = [],
        healthKitService: HealthKitStepsService? = nil
    ) -> StepsManager {
        StepsManager(
            stepsSyncEngine: collectionEngine(entries, key: "steps"),
            healthKitService: healthKitService ?? MockHealthKitStepsService()
        )
    }

    /// A steps manager already listening, so `stepsHistory` holds `entries`.
    static func signedInStepsManager(
        entries: [StepsModel] = [],
        healthKitService: HealthKitStepsService? = nil
    ) async -> StepsManager {
        let manager = stepsManager(entries: entries, healthKitService: healthKitService)
        await manager.signIn()
        await eventually { manager.stepsHistory.count == entries.count }
        return manager
    }
    #endif
}

// MARK: - Nutrition, settings and shortcut managers

@MainActor
extension TestManagers {

    static func foodManager(foods: [FoodModel] = []) -> FoodManager {
        FoodManager(foodSyncEngine: collectionEngine(foods, key: "foods"))
    }

    /// A food manager already listening, so `foods` holds what its remote was given.
    static func signedInFoodManager(foods: [FoodModel]) async -> FoodManager {
        let manager = foodManager(foods: foods)
        await manager.signIn()
        await eventually { manager.foods.count == foods.count }
        return manager
    }

    static func recipeTemplateManager(recipes: [RecipeTemplateModel] = []) -> RecipeTemplateManager {
        RecipeTemplateManager(userRecipeTemplateSyncEngine: collectionEngine(recipes, key: "recipes"))
    }

    /// A recipe manager already listening, so `userRecipeTemplates` holds what its remote was given.
    static func signedInRecipeTemplateManager(recipes: [RecipeTemplateModel]) async -> RecipeTemplateManager {
        let manager = recipeTemplateManager(recipes: recipes)
        await manager.signIn()
        await eventually { manager.userRecipeTemplates.count == recipes.count }
        return manager
    }

    static func foodLogSettingsManager(stored: FoodLogSettings? = nil) -> FoodLogSettingsManager {
        FoodLogSettingsManager(foodLogSettingsSyncEngine: documentEngine(stored, key: "food-log-settings"))
    }

    static func analyticsSettingsManager(stored: AnalyticsSettings? = nil) -> AnalyticsSettingsManager {
        AnalyticsSettingsManager(settingsSyncEngine: documentEngine(stored, key: "analytics-settings"))
    }

    static func shortcutSettingsManager(stored: ShortcutSettings? = nil) -> ShortcutSettingsManager {
        ShortcutSettingsManager(settingsSyncEngine: documentEngine(stored, key: "shortcut-settings"))
    }

    static func nutritionStrategySettingsManager(
        stored: NutritionStrategySettings? = nil
    ) -> NutritionStrategySettingsManager {
        NutritionStrategySettingsManager(
            settingsSyncEngine: documentEngine(stored, key: "nutrition-strategy-settings")
        )
    }
}
