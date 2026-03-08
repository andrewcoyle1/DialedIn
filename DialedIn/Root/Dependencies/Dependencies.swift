//
//  Dependencies.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI
import Firebase

@MainActor
struct Dependencies {
    let container: DependencyContainer
    let logManager: LogManager

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    init(config: BuildConfiguration) {
        
        let authManager: AuthManager
        let userManager: UserManager
        let abTestManager: ABTestManager
        let logManager: LogManager
        let purchaseManager: PurchaseManager
        let appState: AppState
        let hapticManager: HapticManager
        let soundEffectManager: SoundEffectManager

        let exerciseModelManager: ExerciseModelManager
        let exerciseUnitPreferenceManager: ExerciseUnitPreferenceManager
        let workoutSettingsManager: WorkoutSettingsManager
        let workoutTemplateManager: WorkoutTemplateManager
        let workoutSessionManager: WorkoutSessionManager
        let trainingProgramManager: TrainingProgramManager
        let gymProfileManager: GymProfileManager
        let ingredientTemplateManager: IngredientTemplateManager
        let recipeTemplateManager: RecipeTemplateManager
        let nutritionManager: NutritionManager
        let mealLogManager: MealLogManager
        let pushManager: PushManager
        let aiManager: AIManager
        
        let reportManager: ReportManager
        let healthKitManager: HealthKitManager
        let bodyMeasurementsManager: BodyMeasurementsManager
        let stepsManager: StepsManager
        let goalManager: GoalManager
        let streakManager: StreakManager
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        let hkWorkoutManager: HKWorkoutManager
        let liveActivityManager: LiveActivityManager
        #endif
        let imageUploadManager: ImageUploadManager
        let commentsManager: CommentsManager

        switch config {
        case .mock(let scenario):
            logManager = LogManager(services: [
                ConsoleService(printParameters: true)
            ])
            switch scenario {
            case .newAnonymous:
                authManager = AuthManager(service: MockAuthService(scenario: .newAnonymous))
                let userSyncEngine = DocumentSyncEngine<UserModel>(
                    remote: MockRemoteDocumentService(),
                    managerKey: Keys.userManagerKey,
                    enableLocalPersistence: true,
                    logger: logManager
                )
                let followingUsersSyncEngine = CollectionSyncEngine<UserModel>(
                    remote: MockRemoteCollectionService(),
                    managerKey: Keys.followingUsersManagerKey,
                    enableLocalPersistence: true,
                    logger: logManager
                )
                userManager = UserManager(userSyncEngine: userSyncEngine, followingUsersSyncEngine: followingUsersSyncEngine)
                purchaseManager = PurchaseManager(service: MockPurchaseService(availableProducts: AnyProduct.mocks))
                appState = AppState(startingModuleId: Constants.onboardingModuleId)
            case .existingSignedOut:
                authManager = AuthManager(service: MockAuthService(scenario: .existingSignedOut))
                let userSyncEngine = DocumentSyncEngine<UserModel>(
                    remote: MockRemoteDocumentService(),
                    managerKey: Keys.userManagerKey,
                    enableLocalPersistence: true,
                    logger: logManager
                )
                let followingUsersSyncEngine = CollectionSyncEngine<UserModel>(
                    remote: MockRemoteCollectionService(),
                    managerKey: Keys.followingUsersManagerKey,
                    enableLocalPersistence: true,
                    logger: logManager
                )
                userManager = UserManager(userSyncEngine: userSyncEngine, followingUsersSyncEngine: followingUsersSyncEngine)
                purchaseManager = PurchaseManager(service: MockPurchaseService(availableProducts: AnyProduct.mocks))
                appState = AppState(startingModuleId: Constants.onboardingModuleId)
            case .existingSignedIn:
                authManager = AuthManager(service: MockAuthService(scenario: .existingSignedIn))
                let userSyncEngine = DocumentSyncEngine<UserModel>(
                    remote: MockRemoteDocumentService(),
                    managerKey: Keys.userManagerKey,
                    enableLocalPersistence: true,
                    logger: logManager
                )
                let followingUsersSyncEngine = CollectionSyncEngine<UserModel>(
                    remote: MockRemoteCollectionService(),
                    managerKey: Keys.followingUsersManagerKey,
                    enableLocalPersistence: true,
                    logger: logManager
                )
                userManager = UserManager(userSyncEngine: userSyncEngine, followingUsersSyncEngine: followingUsersSyncEngine)
                purchaseManager = PurchaseManager(service: MockPurchaseService(availableProducts: AnyProduct.mocks))
                appState = AppState(startingModuleId: Constants.tabBarModuleId)
            }
            abTestManager = ABTestManager(service: MockABTestService(), logger: logManager)
            let userExerciseSyncEngine = CollectionSyncEngine<ExerciseModel>(
                remote: MockRemoteCollectionService(),
                managerKey: Keys.userExerciseManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            let systemExercisePersistence = MockLocalCollectionPersistence(collection: ExerciseModel.mocks)
            exerciseModelManager = ExerciseModelManager(userExerciseSyncEngine: userExerciseSyncEngine, systemExercisePersistence: systemExercisePersistence)
            exerciseUnitPreferenceManager = ExerciseUnitPreferenceManager(userManager: userManager)
            let workoutSettingsSyncEngine = DocumentSyncEngine<WorkoutSettings>(
                remote: MockRemoteDocumentService(),
                managerKey: Keys.workoutSettingsManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            workoutSettingsManager = WorkoutSettingsManager(workoutSettingsSyncEngine: workoutSettingsSyncEngine)
            let userWorkoutTemplateSyncEngine = CollectionSyncEngine<WorkoutTemplateModel>(
                remote: MockRemoteCollectionService(),
                managerKey: Keys.workoutTemplateManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            let systemWorkoutTemplatePersistence = MockLocalCollectionPersistence<WorkoutTemplateModel>()
            workoutTemplateManager = WorkoutTemplateManager(userWorkoutTemplateSyncEngine: userWorkoutTemplateSyncEngine, systemWorkoutTemplatePersistence: systemWorkoutTemplatePersistence)
            let activeWorkoutSessionPersistence = MockLocalDocumentPersistence<WorkoutSessionModel>()
            let userWorkoutSessionSyncEngine = CollectionSyncEngine<WorkoutSessionModel>(
                remote: MockRemoteCollectionService(),
                managerKey: Keys.userWorkoutSessionManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            let followingWorkoutSessionSyncEngine = CollectionGroupSyncEngine<WorkoutSessionModel>(
                remote: MockRemoteCollectionGroupService(),
                managerKey: Keys.followingWorkoutSessionsManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            workoutSessionManager = WorkoutSessionManager(
                activeWorkoutSessionPersistence: activeWorkoutSessionPersistence,
                userWorkoutSessionSyncEngine: userWorkoutSessionSyncEngine,
                followingWorkoutSessionSyncEngine: followingWorkoutSessionSyncEngine
            )
            let trainingProgramSyncEngine = CollectionSyncEngine<TrainingProgram>(
                remote: MockRemoteCollectionService(),
                managerKey: Keys.trainingProgramManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            trainingProgramManager = TrainingProgramManager(trainingProgramSyncEngine: trainingProgramSyncEngine)
                
            let gymProfileSyncEngine = CollectionSyncEngine<GymProfileModel>(
                remote: MockRemoteCollectionService(),
                managerKey: Keys.gymProfileManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            gymProfileManager = GymProfileManager(gymProfileSyncEngine: gymProfileSyncEngine)

            let ingredientTemplateSyncEngine = CollectionSyncEngine<IngredientTemplateModel>(
                remote: MockRemoteCollectionService(),
                managerKey: Keys.ingredientTemplateManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            ingredientTemplateManager = IngredientTemplateManager(ingredientTemplateSyncEngine: ingredientTemplateSyncEngine)
            
            let userRecipeTemplateSyncEngine = CollectionSyncEngine<RecipeTemplateModel>(
                remote: MockRemoteCollectionService(),
                managerKey: Keys.recipeTemplateManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            recipeTemplateManager = RecipeTemplateManager(userRecipeTemplateSyncEngine: userRecipeTemplateSyncEngine)
            let dietPlanSyncEngine = DocumentSyncEngine<DietPlan>(
                remote: MockRemoteDocumentService(),
                managerKey: Keys.dietPlanManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            nutritionManager = NutritionManager(dietPlanSyncEngine: dietPlanSyncEngine)
            let draftMealLogPersistence = FileManagerDocumentPersistence<MealLogModel>()
            let mealLogSyncEngine = CollectionSyncEngine<MealLogModel>(
                remote: MockRemoteCollectionService(collection: MealLogModel.mockWeekMealsByDay.values.flatMap { $0 }),
                managerKey: Keys.mealLogManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            mealLogManager = MealLogManager(draftMealLogPersistence: draftMealLogPersistence, mealLogSyncEngine: mealLogSyncEngine)
            aiManager = AIManager(service: MockAIService())
            reportManager = ReportManager(service: MockReportService(), userManager: userManager, logManager: logManager)
            let bodyMeasurementsSyncEngine = CollectionSyncEngine<BodyMeasurementEntry>(
                remote: MockRemoteCollectionService(),
                managerKey: Keys.bodyMeasurementsManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            bodyMeasurementsManager = BodyMeasurementsManager(
                bodyMeasurementsSyncEngine: bodyMeasurementsSyncEngine,
                healthKitService: ProductionHealthKitWeightService()
            )
            let stepsSyncEngine = CollectionSyncEngine<StepsModel>(
                remote: MockRemoteCollectionService(),
                managerKey: Keys.stepsManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            stepsManager = StepsManager(stepsSyncEngine: stepsSyncEngine, healthKitService: MockHealthKitStepsService())
            let userGoalSyncEngine = DocumentSyncEngine<WeightGoal>(
                remote: MockRemoteDocumentService(),
                managerKey: Keys.userGoalManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            goalManager = GoalManager(userGoalSyncEngine: userGoalSyncEngine)
            streakManager = StreakManager(
                services: MockStreakServices(),
                configuration: StreakConfiguration(streakKey: "workout", leewayHours: 2),
                logger: logManager
            )
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            hkWorkoutManager = HKWorkoutManager(logger: logManager)
            liveActivityManager = LiveActivityManager(logger: logManager)
            hkWorkoutManager.liveActivityUpdater = liveActivityManager
            #endif
            imageUploadManager = ImageUploadManager(service: MockImageUploadService())
            pushManager = PushManager(logManager: logManager)
            healthKitManager = HealthKitManager(service: HealthKitService())
            commentsManager = CommentsManager(service: MockCommentsService())

        case .dev:
            logManager = LogManager(services: [
                ConsoleService(printParameters: true),
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken, loggingEnabled: false),
                FirebaseCrashlyticsService()
            ])
            
            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
            let userSyncEngine = DocumentSyncEngine<UserModel>(
                remote: FirebaseRemoteDocumentService(collectionPath: { "users" }),
                managerKey: Keys.userManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            let followingUsersSyncEngine = CollectionSyncEngine<UserModel>(
                remote: FirebaseRemoteCollectionService(collectionPath: { "users" }),
                managerKey: Keys.followingUsersManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            userManager = UserManager(userSyncEngine: userSyncEngine, followingUsersSyncEngine: followingUsersSyncEngine)
            abTestManager = ABTestManager(service: LocalABTestService(), logger: logManager)
            purchaseManager = PurchaseManager(service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey), logger: logManager)
            let userExerciseSyncEngine = CollectionSyncEngine<ExerciseModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: {
                        "exercise_templates"
                    }
                ),
                managerKey: Keys.userExerciseManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            let systemExercisePersistence = SwiftDataCollectionPersistence<ExerciseModel>(managerKey: Keys.systemExerciseManagerKey)
            exerciseModelManager = ExerciseModelManager(userExerciseSyncEngine: userExerciseSyncEngine, systemExercisePersistence: systemExercisePersistence)
            exerciseUnitPreferenceManager = ExerciseUnitPreferenceManager(userManager: userManager)
            let workoutSettingsSyncEngine = DocumentSyncEngine<WorkoutSettings>(
                remote: FirebaseRemoteDocumentService(
                    collectionPath: {[weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/workout_settings"
                    }
                ),
                managerKey: Keys.workoutSettingsManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            workoutSettingsManager = WorkoutSettingsManager(workoutSettingsSyncEngine: workoutSettingsSyncEngine)

            let userWorkoutTemplateSyncEngine = CollectionSyncEngine<WorkoutTemplateModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: {[weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/workout_templates"
                    }
                ),
                managerKey: Keys.workoutTemplateManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            let systemWorkoutTemplatePersistence = SwiftDataCollectionPersistence<WorkoutTemplateModel>(managerKey: Keys.systemWorkoutTemplateManagerKey)
            workoutTemplateManager = WorkoutTemplateManager(userWorkoutTemplateSyncEngine: userWorkoutTemplateSyncEngine, systemWorkoutTemplatePersistence: systemWorkoutTemplatePersistence)
            let activeWorkoutSessionPersistence = FileManagerDocumentPersistence<WorkoutSessionModel>()
            let userWorkoutSessionSyncEngine = CollectionSyncEngine<WorkoutSessionModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/workout_sessions"
                    }
                ),
                managerKey: Keys.userWorkoutSessionManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            let followingWorkoutSessionsSyncEngine = CollectionGroupSyncEngine<WorkoutSessionModel>(
                remote: FirebaseRemoteCollectionGroupService(collectionGroupName: "workout_sessions"),
                managerKey: Keys.followingWorkoutSessionsManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            workoutSessionManager = WorkoutSessionManager(
                activeWorkoutSessionPersistence: activeWorkoutSessionPersistence,
                userWorkoutSessionSyncEngine: userWorkoutSessionSyncEngine,
                followingWorkoutSessionSyncEngine: followingWorkoutSessionsSyncEngine
            )
            let trainingProgramSyncEngine = CollectionSyncEngine<TrainingProgram>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/training_programs"
                    }
                ),
                managerKey: Keys.trainingProgramManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            trainingProgramManager = TrainingProgramManager(trainingProgramSyncEngine: trainingProgramSyncEngine)
            let gymProfileSyncEngine = CollectionSyncEngine<GymProfileModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [ weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/gym_profiles"
                    }
                ),
                managerKey: Keys.gymProfileManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            gymProfileManager = GymProfileManager(gymProfileSyncEngine: gymProfileSyncEngine)

            let ingredientTemplateSyncEngine = CollectionSyncEngine<IngredientTemplateModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [ weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/ingredient_templates"
                    }
                ),
                managerKey: Keys.ingredientTemplateManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            ingredientTemplateManager = IngredientTemplateManager(ingredientTemplateSyncEngine: ingredientTemplateSyncEngine)
            let userRecipeTemplateSyncEngine = CollectionSyncEngine<RecipeTemplateModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [ weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/recipe_templates"
                    }
                ),
                managerKey: Keys.recipeTemplateManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            recipeTemplateManager = RecipeTemplateManager(userRecipeTemplateSyncEngine: userRecipeTemplateSyncEngine)
            let dietPlanSyncEngine = DocumentSyncEngine<DietPlan>(
                remote: FirebaseRemoteDocumentService(
                    collectionPath: { "diet_plans" }
                ),
                managerKey: Keys.dietPlanManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            nutritionManager = NutritionManager(dietPlanSyncEngine: dietPlanSyncEngine)
            let draftMealLogPersistence = FileManagerDocumentPersistence<MealLogModel>()
            let mealLogSyncEngine = CollectionSyncEngine<MealLogModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/meal_logs"
                    }
                ),
                managerKey: Keys.mealLogManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            mealLogManager = MealLogManager(draftMealLogPersistence: draftMealLogPersistence, mealLogSyncEngine: mealLogSyncEngine)
            aiManager = AIManager(service: GoogleAIService())
            reportManager = ReportManager(service: FirebaseReportService(), userManager: userManager, logManager: logManager)
            let bodyMeasurementsSyncEngine = CollectionSyncEngine<BodyMeasurementEntry>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [ weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/body_measurements"
                    }
                ),
                managerKey: Keys.bodyMeasurementsManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            bodyMeasurementsManager = BodyMeasurementsManager(
                bodyMeasurementsSyncEngine: bodyMeasurementsSyncEngine,
                healthKitService: ProductionHealthKitWeightService()
            )
            let stepsSyncEngine = CollectionSyncEngine<StepsModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [ weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/steps"
                    }
                ),
                managerKey: Keys.stepsManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            stepsManager = StepsManager(stepsSyncEngine: stepsSyncEngine, healthKitService: ProductionHealthKitStepsService())
            let userGoalSyncEngine = DocumentSyncEngine<WeightGoal>(
                remote: FirebaseRemoteDocumentService(
                    collectionPath: { [ weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/goals"
                    }
                ),
                managerKey: Keys.userGoalManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            goalManager = GoalManager(userGoalSyncEngine: userGoalSyncEngine)
            streakManager = StreakManager(
                services: ProductionStreakServices(rootCollectionName: "user_streaks"), 
                configuration: StreakConfiguration(streakKey: "workout", leewayHours: 2),
                logger: logManager
            )
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            hkWorkoutManager = HKWorkoutManager(logger: logManager)
            liveActivityManager = LiveActivityManager(logger: logManager)
            hkWorkoutManager.liveActivityUpdater = liveActivityManager
            #endif
            appState = AppState()
            imageUploadManager = ImageUploadManager(service: FirebaseImageUploadService())
            pushManager = PushManager(logManager: logManager)
            healthKitManager = HealthKitManager(service: HealthKitService())
            commentsManager = CommentsManager(service: FirebaseCommentsService())

        case .prod:
            logManager = LogManager(services: [
                ConsoleService(),
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
            let userSyncEngine = DocumentSyncEngine<UserModel>(
                remote: FirebaseRemoteDocumentService(collectionPath: { "users" }),
                managerKey: Keys.userManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            let followingUsersSyncEngine = CollectionSyncEngine<UserModel>(
                remote: FirebaseRemoteCollectionService(collectionPath: { "users" }),
                managerKey: Keys.followingUsersManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            userManager = UserManager(userSyncEngine: userSyncEngine, followingUsersSyncEngine: followingUsersSyncEngine)
            abTestManager = ABTestManager(service: FirebaseABTestService(), logger: logManager)
            purchaseManager = PurchaseManager(service: StoreKitPurchaseService())
            let userExerciseSyncEngine = CollectionSyncEngine<ExerciseModel>(
                remote: FirebaseRemoteCollectionService(collectionPath: { "exercise_templates" }),
                managerKey: Keys.userExerciseManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            let systemExercisePersistence = SwiftDataCollectionPersistence<ExerciseModel>(managerKey: Keys.systemExerciseManagerKey)
            exerciseModelManager = ExerciseModelManager(userExerciseSyncEngine: userExerciseSyncEngine, systemExercisePersistence: systemExercisePersistence)
            exerciseUnitPreferenceManager = ExerciseUnitPreferenceManager(userManager: userManager)
            let workoutSettingsSyncEngine = DocumentSyncEngine<WorkoutSettings>(
                remote: FirebaseRemoteDocumentService(
                    collectionPath: {[weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/workout_settings"
                    }
                ),
                managerKey: Keys.workoutSettingsManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            workoutSettingsManager = WorkoutSettingsManager(workoutSettingsSyncEngine: workoutSettingsSyncEngine)
            let userWorkoutTemplateSyncEngine = CollectionSyncEngine<WorkoutTemplateModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: {[weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/workout_templates"
                    }
                ),
                managerKey: Keys.workoutTemplateManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            let systemWorkoutTemplatePersistence = SwiftDataCollectionPersistence<WorkoutTemplateModel>(managerKey: Keys.systemWorkoutTemplateManagerKey)
            workoutTemplateManager = WorkoutTemplateManager(userWorkoutTemplateSyncEngine: userWorkoutTemplateSyncEngine, systemWorkoutTemplatePersistence: systemWorkoutTemplatePersistence)
            let activeWorkoutSessionPersistence = FileManagerDocumentPersistence<WorkoutSessionModel>()
            let userWorkoutSessionSyncEngine = CollectionSyncEngine<WorkoutSessionModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/workout_sessions"
                    }
                ),
                managerKey: Keys.userWorkoutSessionManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            let followingWorkoutSessionsSyncEngine = CollectionGroupSyncEngine<WorkoutSessionModel>(
                remote: FirebaseRemoteCollectionGroupService(collectionGroupName: "workout_sessions"),
                managerKey: Keys.followingWorkoutSessionsManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            workoutSessionManager = WorkoutSessionManager(
                activeWorkoutSessionPersistence: activeWorkoutSessionPersistence,
                userWorkoutSessionSyncEngine: userWorkoutSessionSyncEngine,
                followingWorkoutSessionSyncEngine: followingWorkoutSessionsSyncEngine
            )
            let trainingProgramSyncEngine = CollectionSyncEngine<TrainingProgram>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/training_programs"
                    }
                ),
                managerKey: Keys.trainingProgramManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            trainingProgramManager = TrainingProgramManager(trainingProgramSyncEngine: trainingProgramSyncEngine)
            let gymProfileSyncEngine = CollectionSyncEngine<GymProfileModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [ weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/gym_profiles"
                    }
                ),
                managerKey: Keys.gymProfileManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            gymProfileManager = GymProfileManager(gymProfileSyncEngine: gymProfileSyncEngine)

            let ingredientTemplateSyncEngine = CollectionSyncEngine<IngredientTemplateModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [ weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/ingredient_templates"
                    }
                ),
                managerKey: Keys.ingredientTemplateManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            ingredientTemplateManager = IngredientTemplateManager(ingredientTemplateSyncEngine: ingredientTemplateSyncEngine)
            let userRecipeTemplateSyncEngine = CollectionSyncEngine<RecipeTemplateModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [ weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/recipe_templates"
                    }
                ),
                managerKey: Keys.recipeTemplateManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            recipeTemplateManager = RecipeTemplateManager(userRecipeTemplateSyncEngine: userRecipeTemplateSyncEngine)
            let dietPlanSyncEngine = DocumentSyncEngine<DietPlan>(
                remote: FirebaseRemoteDocumentService(
                    collectionPath: { "diet_plans" }
                ),
                managerKey: Keys.dietPlanManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            nutritionManager = NutritionManager(dietPlanSyncEngine: dietPlanSyncEngine)
            let draftMealLogPersistence = FileManagerDocumentPersistence<MealLogModel>()
            let mealLogSyncEngine = CollectionSyncEngine<MealLogModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/meal_logs"
                    }
                ),
                managerKey: Keys.mealLogManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            mealLogManager = MealLogManager(draftMealLogPersistence: draftMealLogPersistence, mealLogSyncEngine: mealLogSyncEngine)
            aiManager = AIManager(service: GoogleAIService())
            reportManager = ReportManager(service: FirebaseReportService(), userManager: userManager, logManager: logManager)
            let bodyMeasurementsSyncEngine = CollectionSyncEngine<BodyMeasurementEntry>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [ weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/body_measurements"
                    }
                ),
                managerKey: Keys.bodyMeasurementsManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            bodyMeasurementsManager = BodyMeasurementsManager(
                bodyMeasurementsSyncEngine: bodyMeasurementsSyncEngine,
                healthKitService: ProductionHealthKitWeightService()
            )
            let stepsSyncEngine = CollectionSyncEngine<StepsModel>(
                remote: FirebaseRemoteCollectionService(
                    collectionPath: { [ weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/steps"
                    }
                ),
                managerKey: Keys.stepsManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            stepsManager = StepsManager(stepsSyncEngine: stepsSyncEngine, healthKitService: ProductionHealthKitStepsService())
            let userGoalSyncEngine = DocumentSyncEngine<WeightGoal>(
                remote: FirebaseRemoteDocumentService(
                    collectionPath: { [ weak authManager] in
                        guard let uid = authManager?.auth?.uid else { return nil }
                        return "users/\(uid)/goals"
                    }
                ),
                managerKey: Keys.userGoalManagerKey,
                enableLocalPersistence: true,
                logger: logManager
            )
            goalManager = GoalManager(userGoalSyncEngine: userGoalSyncEngine)
            streakManager = StreakManager(
                services: ProductionStreakServices(rootCollectionName: "user_streaks"),
                configuration: StreakConfiguration(streakKey: "workout", leewayHours: 2),
                logger: logManager
            )
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            hkWorkoutManager = HKWorkoutManager(logger: logManager)
            liveActivityManager = LiveActivityManager(logger: logManager)
            hkWorkoutManager.liveActivityUpdater = liveActivityManager
            #endif
            appState = AppState()
            imageUploadManager = ImageUploadManager(service: FirebaseImageUploadService())
            pushManager = PushManager(logManager: logManager)
            healthKitManager = HealthKitManager(service: HealthKitService())
            commentsManager = CommentsManager(service: FirebaseCommentsService())
        }
        hapticManager = HapticManager(logger: logManager)
        soundEffectManager = SoundEffectManager(logger: logManager)

        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(ABTestManager.self, service: abTestManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(LogManager.self, service: logManager)
        container.register(ExerciseModelManager.self, service: exerciseModelManager)
        container.register(ExerciseUnitPreferenceManager.self, service: exerciseUnitPreferenceManager)
        container.register(WorkoutSettingsManager.self, service: workoutSettingsManager)
        container.register(WorkoutTemplateManager.self, service: workoutTemplateManager)
        container.register(WorkoutSessionManager.self, service: workoutSessionManager)
        container.register(TrainingProgramManager.self, service: trainingProgramManager)
        container.register(GymProfileManager.self, service: gymProfileManager)
        container.register(IngredientTemplateManager.self, service: ingredientTemplateManager)
        container.register(RecipeTemplateManager.self, service: recipeTemplateManager)
        container.register(NutritionManager.self, service: nutritionManager)
        container.register(MealLogManager.self, service: mealLogManager)
        container.register(PushManager.self, service: pushManager)
        container.register(AIManager.self, service: aiManager)
        container.register(ReportManager.self, service: reportManager)
        container.register(HealthKitManager.self, service: healthKitManager)
        container.register(BodyMeasurementsManager.self, service: bodyMeasurementsManager)
        container.register(StepsManager.self, service: stepsManager)
        container.register(GoalManager.self, service: goalManager)
        container.register(StreakManager.self, service: streakManager)
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        container.register(HKWorkoutManager.self, service: hkWorkoutManager)
        container.register(LiveActivityManager.self, service: liveActivityManager)
        #endif
        container.register(AppState.self, service: appState)
        container.register(ImageUploadManager.self, service: imageUploadManager)
        container.register(HapticManager.self, service: hapticManager)
        container.register(SoundEffectManager.self, service: soundEffectManager)
        container.register(CommentsManager.self, service: commentsManager)

        self.logManager = logManager
        self.container = container
    }
}

@MainActor
class DevPreview {
    static let shared = DevPreview()
    
    func container() -> DependencyContainer {
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(ABTestManager.self, service: abTestManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(ExerciseModelManager.self, service: exerciseModelManager)
        container.register(ExerciseUnitPreferenceManager.self, service: exerciseUnitPreferenceManager)
        container.register(WorkoutSettingsManager.self, service: workoutSettingsManager)
        container.register(WorkoutTemplateManager.self, service: workoutTemplateManager)
        container.register(WorkoutSessionManager.self, service: workoutSessionManager)
        container.register(TrainingProgramManager.self, service: trainingProgramManager)
        container.register(GymProfileManager.self, service: gymProfileManager)
        container.register(IngredientTemplateManager.self, service: ingredientTemplateManager)
        container.register(RecipeTemplateManager.self, service: recipeTemplateManager)
        container.register(NutritionManager.self, service: nutritionManager)
        container.register(MealLogManager.self, service: mealLogManager)
        container.register(PushManager.self, service: pushManager)
        container.register(AIManager.self, service: aiManager)
        container.register(LogManager.self, service: logManager)
        container.register(ReportManager.self, service: reportManager)
        container.register(HealthKitManager.self, service: healthKitManager)
        container.register(BodyMeasurementsManager.self, service: bodyMeasurementsManager)
        container.register(StepsManager.self, service: stepsManager)
        container.register(GoalManager.self, service: goalManager)
        container.register(StreakManager.self, service: streakManager)
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        container.register(HKWorkoutManager.self, service: hkWorkoutManager)
        container.register(LiveActivityManager.self, service: liveActivityManager)
        #endif
        container.register(AppState.self, service: appState)
        container.register(ImageUploadManager.self, service: imageUploadManager)
        container.register(SoundEffectManager.self, service: soundEffectManager)
        container.register(HapticManager.self, service: hapticManager)
        container.register(CommentsManager.self, service: commentsManager)

        return container
    }

    let authManager: AuthManager
    let userManager: UserManager
    let abTestManager: ABTestManager
    let purchaseManager: PurchaseManager
    let exerciseModelManager: ExerciseModelManager
    let exerciseUnitPreferenceManager: ExerciseUnitPreferenceManager
    let workoutSettingsManager: WorkoutSettingsManager
    let workoutTemplateManager: WorkoutTemplateManager
    let workoutSessionManager: WorkoutSessionManager
    let trainingProgramManager: TrainingProgramManager
    let gymProfileManager: GymProfileManager
    let ingredientTemplateManager: IngredientTemplateManager
    let recipeTemplateManager: RecipeTemplateManager
    let nutritionManager: NutritionManager
    let mealLogManager: MealLogManager
    let pushManager: PushManager
    let aiManager: AIManager
    let logManager: LogManager
    let reportManager: ReportManager
    let healthKitManager: HealthKitManager
    let bodyMeasurementsManager: BodyMeasurementsManager
    let stepsManager: StepsManager
    let goalManager: GoalManager
    let streakManager: StreakManager
    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
    let hkWorkoutManager: HKWorkoutManager
    let liveActivityManager: LiveActivityManager
    #endif
    let appState: AppState

    let hapticManager: HapticManager
    let soundEffectManager: SoundEffectManager

    let imageUploadManager: ImageUploadManager
    let commentsManager: CommentsManager

    // swiftlint:disable:next function_body_length
    init(isSignedIn: Bool = true) {
        let logManager = LogManager(services: [ConsoleService(printParameters: true)])
        let userSyncEngine = DocumentSyncEngine<UserModel>(
            remote: MockRemoteDocumentService(document: .mockExisting),
            managerKey: Keys.userManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        let followingUsersSyncEngine = CollectionSyncEngine<UserModel>(
            remote: MockRemoteCollectionService(collection: UserModel.mocks),
            managerKey: Keys.followingUsersManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        let userManager = UserManager(userSyncEngine: userSyncEngine, followingUsersSyncEngine: followingUsersSyncEngine)
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        hkWorkoutManager = HKWorkoutManager(logger: logManager)
        #endif
        
        self.authManager = AuthManager(service: MockAuthService(scenario: isSignedIn ? .existingSignedIn : .newAnonymous), logger: logManager)
        self.userManager = userManager
        self.abTestManager = ABTestManager(service: MockABTestService(), logger: logManager)
        self.purchaseManager = PurchaseManager(service: MockPurchaseService())
        let userExerciseSyncEngine = CollectionSyncEngine<ExerciseModel>(
            remote: MockRemoteCollectionService(),
            managerKey: Keys.userExerciseManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        let systemExercisePersistence = MockLocalCollectionPersistence(collection: ExerciseModel.mocks)
        self.exerciseModelManager = ExerciseModelManager(userExerciseSyncEngine: userExerciseSyncEngine, systemExercisePersistence: systemExercisePersistence)
        self.exerciseUnitPreferenceManager = ExerciseUnitPreferenceManager(userManager: userManager)
        let workoutSettingsSyncEngine = DocumentSyncEngine<WorkoutSettings>(
            remote: MockRemoteDocumentService(),
            managerKey: Keys.workoutSettingsManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        self.workoutSettingsManager = WorkoutSettingsManager(workoutSettingsSyncEngine: workoutSettingsSyncEngine)
        let userWorkoutTemplateSyncEngine = CollectionSyncEngine<WorkoutTemplateModel>(
            remote: MockRemoteCollectionService(),
            managerKey: Keys.workoutTemplateManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        let systemWorkoutTemplatePersistence = MockLocalCollectionPersistence<WorkoutTemplateModel>()
        workoutTemplateManager = WorkoutTemplateManager(userWorkoutTemplateSyncEngine: userWorkoutTemplateSyncEngine, systemWorkoutTemplatePersistence: systemWorkoutTemplatePersistence)
        let activeWorkoutSessionPersistence = MockLocalDocumentPersistence<WorkoutSessionModel>()
        let userWorkoutSessionSyncEngine = CollectionSyncEngine<WorkoutSessionModel>(
            remote: MockRemoteCollectionService(),
            managerKey: Keys.userWorkoutSessionManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        let followingWorkoutSessionSyncEngine = CollectionGroupSyncEngine<WorkoutSessionModel>(
            remote: MockRemoteCollectionGroupService(),
            managerKey: Keys.followingWorkoutSessionsManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        workoutSessionManager = WorkoutSessionManager(
            activeWorkoutSessionPersistence: activeWorkoutSessionPersistence,
            userWorkoutSessionSyncEngine: userWorkoutSessionSyncEngine,
            followingWorkoutSessionSyncEngine: followingWorkoutSessionSyncEngine
        )
        let trainingProgramSyncEngine = CollectionSyncEngine<TrainingProgram>(
            remote: MockRemoteCollectionService(),
            managerKey: Keys.trainingProgramManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        self.trainingProgramManager = TrainingProgramManager(trainingProgramSyncEngine: trainingProgramSyncEngine)
        let gymProfileSyncEngine = CollectionSyncEngine<GymProfileModel>(
            remote: MockRemoteCollectionService(),
            managerKey: Keys.gymProfileManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        gymProfileManager = GymProfileManager(gymProfileSyncEngine: gymProfileSyncEngine)

        let ingredientTemplateSyncEngine = CollectionSyncEngine<IngredientTemplateModel>(
            remote: MockRemoteCollectionService(),
            managerKey: Keys.ingredientTemplateManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        self.ingredientTemplateManager = IngredientTemplateManager(ingredientTemplateSyncEngine: ingredientTemplateSyncEngine)
        let userRecipeTemplateSyncEngine = CollectionSyncEngine<RecipeTemplateModel>(
            remote: MockRemoteCollectionService(),
            managerKey: Keys.recipeTemplateManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        self.recipeTemplateManager = RecipeTemplateManager(userRecipeTemplateSyncEngine: userRecipeTemplateSyncEngine)
        let dietPlanSyncEngine = DocumentSyncEngine<DietPlan>(
            remote: MockRemoteDocumentService(),
            managerKey: Keys.dietPlanManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        nutritionManager = NutritionManager(dietPlanSyncEngine: dietPlanSyncEngine)
        let draftMealLogPersistence = FileManagerDocumentPersistence<MealLogModel>()
        let mealLogSyncEngine = CollectionSyncEngine<MealLogModel>(
            remote: MockRemoteCollectionService(collection: MealLogModel.previewWeekMealsByDay.values.flatMap { $0 }),
            managerKey: Keys.mealLogManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        self.mealLogManager = MealLogManager(draftMealLogPersistence: draftMealLogPersistence, mealLogSyncEngine: mealLogSyncEngine)
        self.aiManager = AIManager(service: MockAIService())
        self.pushManager = PushManager(logManager: logManager)
        self.logManager = logManager
        self.reportManager = ReportManager(service: MockReportService(), userManager: userManager)
        self.healthKitManager = HealthKitManager(service: MockHealthService())
        let bodyMeasurementsSyncEngine = CollectionSyncEngine<BodyMeasurementEntry>(
            remote: MockRemoteCollectionService(),
            managerKey: Keys.bodyMeasurementsManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        bodyMeasurementsManager = BodyMeasurementsManager(
            bodyMeasurementsSyncEngine: bodyMeasurementsSyncEngine,
            healthKitService: ProductionHealthKitWeightService()
        )
        let stepsSyncEngine = CollectionSyncEngine<StepsModel>(
            remote: MockRemoteCollectionService(),
            managerKey: Keys.stepsManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        stepsManager = StepsManager(stepsSyncEngine: stepsSyncEngine, healthKitService: MockHealthKitStepsService())
        let userGoalSyncEngine = DocumentSyncEngine<WeightGoal>(
            remote: MockRemoteDocumentService(),
            managerKey: Keys.userGoalManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        self.goalManager = GoalManager(userGoalSyncEngine: userGoalSyncEngine)
        self.streakManager = StreakManager(
            services: MockStreakServices(),
            configuration: StreakConfiguration(streakKey: "workout", leewayHours: 2),
            logger: logManager
        )
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        liveActivityManager = LiveActivityManager(logger: logManager)
        self.hkWorkoutManager.liveActivityUpdater = liveActivityManager
        #endif
        self.appState = AppState(startingModuleId: isSignedIn ? Constants.tabBarModuleId : Constants.onboardingModuleId)
        self.imageUploadManager = ImageUploadManager(service: MockImageUploadService())
        self.commentsManager = CommentsManager(service: MockCommentsService())
        self.hapticManager = HapticManager()
        self.soundEffectManager = SoundEffectManager()

    }
}
