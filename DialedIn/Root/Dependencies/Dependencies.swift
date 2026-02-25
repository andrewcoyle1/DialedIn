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

    // swiftlint:disable:next function_body_length
    init(config: BuildConfiguration) {
        
        let authManager: AuthManager
        let userManager: UserManager
        let abTestManager: ABTestManager
        let logManager: LogManager
        let purchaseManager: PurchaseManager
        let appState: AppState
        let hapticManager: HapticManager
        let soundEffectManager: SoundEffectManager

        let exerciseTemplateManager: ExerciseTemplateManager
        let exerciseUnitPreferenceManager: ExerciseUnitPreferenceManager
        let workoutSettingsManager: WorkoutSettingsManager
        let workoutTemplateManager: WorkoutTemplateManager
        let workoutSessionManager: WorkoutSessionManager
        let exerciseHistoryManager: ExerciseHistoryManager
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
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        let hkWorkoutManager: HKWorkoutManager
        let liveActivityManager: LiveActivityManager
        #endif
        let imageUploadManager: ImageUploadManager
        
        switch config {
        case .mock(let scenario):
            logManager = LogManager(services: [
                ConsoleService(printParameters: true)
            ])
            switch scenario {
            case .newAnonymous:
                authManager = AuthManager(service: MockAuthService(scenario: .newAnonymous))
                userManager = UserManager(services: MockUserServices(user: nil))
                purchaseManager = PurchaseManager(service: MockPurchaseService(availableProducts: AnyProduct.mocks))
                appState = AppState(startingModuleId: Constants.onboardingModuleId)
            case .existingSignedOut:
                authManager = AuthManager(service: MockAuthService(scenario: .existingSignedOut))
                userManager = UserManager(services: MockUserServices(user: .mockExisting))
                purchaseManager = PurchaseManager(service: MockPurchaseService(availableProducts: AnyProduct.mocks))
                appState = AppState(startingModuleId: Constants.onboardingModuleId)
            case .existingSignedIn:
                authManager = AuthManager(service: MockAuthService(scenario: .existingSignedIn))
                userManager = UserManager(services: MockUserServices(user: .mockExisting))
                purchaseManager = PurchaseManager(service: MockPurchaseService(availableProducts: AnyProduct.mocks))
                appState = AppState(startingModuleId: Constants.tabBarModuleId)
            }
            abTestManager = ABTestManager(service: MockABTestService(), logger: logManager)
            exerciseTemplateManager = ExerciseTemplateManager(services: MockExerciseTemplateServices())
            exerciseUnitPreferenceManager = ExerciseUnitPreferenceManager(userManager: userManager)
            workoutSettingsManager = WorkoutSettingsManager(userManager: userManager)
            workoutTemplateManager = WorkoutTemplateManager(services: MockWorkoutTemplateServices(), exerciseManager: exerciseTemplateManager)
            workoutSessionManager = WorkoutSessionManager(services: MockWorkoutSessionServices())
            exerciseHistoryManager = ExerciseHistoryManager(services: MockExerciseHistoryServices())
            trainingProgramManager = TrainingProgramManager(services: MockTrainingProgramServices())
            gymProfileManager = GymProfileManager(services: MockGymProfileServices())

            ingredientTemplateManager = IngredientTemplateManager(services: MockIngredientTemplateServices())
            recipeTemplateManager = RecipeTemplateManager(services: MockRecipeTemplateServices())
            nutritionManager = NutritionManager(services: MockNutritionServices())
            mealLogManager = MealLogManager(services: MockMealLogServices(mealsByDay: MealLogModel.mockWeekMealsByDay))
            aiManager = AIManager(service: MockAIService())
            reportManager = ReportManager(service: MockReportService(), userManager: userManager, logManager: logManager)
            bodyMeasurementsManager = BodyMeasurementsManager(services: MockBodyMeasurementServices())
            stepsManager = StepsManager(services: MockStepsServices())
            goalManager = GoalManager(services: MockGoalServices())
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            hkWorkoutManager = HKWorkoutManager()
            liveActivityManager = LiveActivityManager()
            hkWorkoutManager.liveActivityUpdater = liveActivityManager
            #endif
            imageUploadManager = ImageUploadManager(service: MockImageUploadService())
            pushManager = PushManager(logManager: logManager)
            healthKitManager = HealthKitManager(service: HealthKitService())

        case .dev:
            logManager = LogManager(services: [
                ConsoleService(printParameters: true),
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken, loggingEnabled: false),
                FirebaseCrashlyticsService()
            ])
            
            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            abTestManager = ABTestManager(service: LocalABTestService(), logger: logManager)
            purchaseManager = PurchaseManager(service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey), logger: logManager)
            exerciseTemplateManager = ExerciseTemplateManager(services: ProductionExerciseTemplateServices())
            exerciseUnitPreferenceManager = ExerciseUnitPreferenceManager(userManager: userManager)
            workoutSettingsManager = WorkoutSettingsManager(userManager: userManager)
            workoutTemplateManager = WorkoutTemplateManager(services: ProductionWorkoutTemplateServices(exerciseManager: exerciseTemplateManager), exerciseManager: exerciseTemplateManager)
            workoutSessionManager = WorkoutSessionManager(services: ProductionWorkoutSessionServices(logManager: logManager))
            exerciseHistoryManager = ExerciseHistoryManager(services: ProductionExerciseHistoryServices())
            trainingProgramManager = TrainingProgramManager(services: ProductionTrainingProgramServices())
            gymProfileManager = GymProfileManager(services: ProductionGymProfileServices())

            ingredientTemplateManager = IngredientTemplateManager(services: ProductionIngredientTemplateServices())
            recipeTemplateManager = RecipeTemplateManager(services: ProductionRecipeTemplateServices())
            nutritionManager = NutritionManager(services: ProductionNutritionServices())
            mealLogManager = MealLogManager(services: ProductionMealLogServices())
            aiManager = AIManager(service: GoogleAIService())
            reportManager = ReportManager(service: FirebaseReportService(), userManager: userManager, logManager: logManager)
            bodyMeasurementsManager = BodyMeasurementsManager(services: ProductionBodyMeasurementServices())
            stepsManager = StepsManager(services: ProductionStepsServices())
            goalManager = GoalManager(services: ProductionGoalServices())
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            hkWorkoutManager = HKWorkoutManager()
            liveActivityManager = LiveActivityManager()
            hkWorkoutManager.liveActivityUpdater = liveActivityManager
            #endif
            appState = AppState()
            imageUploadManager = ImageUploadManager(service: FirebaseImageUploadService())
            pushManager = PushManager(logManager: logManager)
            healthKitManager = HealthKitManager(service: HealthKitService())

        case .prod:
            logManager = LogManager(services: [
                ConsoleService(),
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            abTestManager = ABTestManager(service: FirebaseABTestService(), logger: logManager)
            purchaseManager = PurchaseManager(service: StoreKitPurchaseService())
            exerciseTemplateManager = ExerciseTemplateManager(services: ProductionExerciseTemplateServices())
            exerciseUnitPreferenceManager = ExerciseUnitPreferenceManager(userManager: userManager)
            workoutSettingsManager = WorkoutSettingsManager(userManager: userManager)
            workoutTemplateManager = WorkoutTemplateManager(services: ProductionWorkoutTemplateServices(exerciseManager: exerciseTemplateManager), exerciseManager: exerciseTemplateManager)
            workoutSessionManager = WorkoutSessionManager(services: ProductionWorkoutSessionServices(logManager: logManager))
            exerciseHistoryManager = ExerciseHistoryManager(services: ProductionExerciseHistoryServices())
            trainingProgramManager = TrainingProgramManager(services: ProductionTrainingProgramServices())
            gymProfileManager = GymProfileManager(services: ProductionGymProfileServices())

            ingredientTemplateManager = IngredientTemplateManager(services: ProductionIngredientTemplateServices())
            recipeTemplateManager = RecipeTemplateManager(services: ProductionRecipeTemplateServices())
            nutritionManager = NutritionManager(services: ProductionNutritionServices())
            mealLogManager = MealLogManager(services: ProductionMealLogServices())
            aiManager = AIManager(service: GoogleAIService())
            reportManager = ReportManager(service: FirebaseReportService(), userManager: userManager, logManager: logManager)
            bodyMeasurementsManager = BodyMeasurementsManager(services: ProductionBodyMeasurementServices())
            stepsManager = StepsManager(services: ProductionStepsServices())
            goalManager = GoalManager(services: ProductionGoalServices())
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            hkWorkoutManager = HKWorkoutManager()
            liveActivityManager = LiveActivityManager()
            hkWorkoutManager.liveActivityUpdater = liveActivityManager
            #endif
            appState = AppState()
            imageUploadManager = ImageUploadManager(service: FirebaseImageUploadService())
            pushManager = PushManager(logManager: logManager)
            healthKitManager = HealthKitManager(service: HealthKitService())
        }
        hapticManager = HapticManager(logger: logManager)
        soundEffectManager = SoundEffectManager(logger: logManager)

        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(ABTestManager.self, service: abTestManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(LogManager.self, service: logManager)
        container.register(ExerciseTemplateManager.self, service: exerciseTemplateManager)
        container.register(ExerciseUnitPreferenceManager.self, service: exerciseUnitPreferenceManager)
        container.register(WorkoutSettingsManager.self, service: workoutSettingsManager)
        container.register(WorkoutTemplateManager.self, service: workoutTemplateManager)
        container.register(WorkoutSessionManager.self, service: workoutSessionManager)
        container.register(ExerciseHistoryManager.self, service: exerciseHistoryManager)
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
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        container.register(HKWorkoutManager.self, service: hkWorkoutManager)
        container.register(LiveActivityManager.self, service: liveActivityManager)
        #endif
        container.register(AppState.self, service: appState)
        container.register(ImageUploadManager.self, service: imageUploadManager)
        container.register(HapticManager.self, service: hapticManager)
        container.register(SoundEffectManager.self, service: soundEffectManager)

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
        container.register(ExerciseTemplateManager.self, service: exerciseTemplateManager)
        container.register(ExerciseUnitPreferenceManager.self, service: exerciseUnitPreferenceManager)
        container.register(WorkoutSettingsManager.self, service: workoutSettingsManager)
        container.register(WorkoutTemplateManager.self, service: workoutTemplateManager)
        container.register(WorkoutSessionManager.self, service: workoutSessionManager)
        container.register(ExerciseHistoryManager.self, service: exerciseHistoryManager)
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
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        container.register(HKWorkoutManager.self, service: hkWorkoutManager)
        container.register(LiveActivityManager.self, service: liveActivityManager)
        #endif
        container.register(AppState.self, service: appState)
        container.register(ImageUploadManager.self, service: imageUploadManager)
        container.register(SoundEffectManager.self, service: soundEffectManager)
        container.register(HapticManager.self, service: hapticManager)

        return container
    }
    
    let authManager: AuthManager
    let userManager: UserManager
    let abTestManager: ABTestManager
    let purchaseManager: PurchaseManager
    let exerciseTemplateManager: ExerciseTemplateManager
    let exerciseUnitPreferenceManager: ExerciseUnitPreferenceManager
    let workoutSettingsManager: WorkoutSettingsManager
    let workoutTemplateManager: WorkoutTemplateManager
    let workoutSessionManager: WorkoutSessionManager
    let exerciseHistoryManager: ExerciseHistoryManager
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
    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
    let hkWorkoutManager: HKWorkoutManager
    let liveActivityManager: LiveActivityManager
    #endif
    let appState: AppState

    let hapticManager: HapticManager
    let soundEffectManager: SoundEffectManager

    let imageUploadManager: ImageUploadManager
    
    init(isSignedIn: Bool = true) {
        let logManager = LogManager(services: [ConsoleService(printParameters: true)])
        let userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mockExisting : nil))
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        let hkWorkoutManager = HKWorkoutManager()
        #endif
        
        self.authManager = AuthManager(service: MockAuthService(scenario: isSignedIn ? .existingSignedIn : .newAnonymous), logger: logManager)
        self.userManager = userManager
        self.abTestManager = ABTestManager(service: MockABTestService(), logger: logManager)
        self.purchaseManager = PurchaseManager(service: MockPurchaseService())
        self.exerciseTemplateManager = ExerciseTemplateManager(services: MockExerciseTemplateServices())
        self.exerciseUnitPreferenceManager = ExerciseUnitPreferenceManager(userManager: userManager)
        self.workoutSettingsManager = WorkoutSettingsManager(userManager: userManager)
        self.workoutTemplateManager = WorkoutTemplateManager(services: MockWorkoutTemplateServices(), exerciseManager: ExerciseTemplateManager(services: MockExerciseTemplateServices()))
        self.workoutSessionManager = WorkoutSessionManager(services: MockWorkoutSessionServices())
        self.exerciseHistoryManager = ExerciseHistoryManager(services: MockExerciseHistoryServices())
        self.trainingProgramManager = TrainingProgramManager(services: MockTrainingProgramServices())
        self.gymProfileManager = GymProfileManager(services: MockGymProfileServices())
        
        self.ingredientTemplateManager = IngredientTemplateManager(services: MockIngredientTemplateServices())
        self.recipeTemplateManager = RecipeTemplateManager(services: MockRecipeTemplateServices())
        self.nutritionManager = NutritionManager(services: MockNutritionServices())
        self.mealLogManager = MealLogManager(services: MockMealLogServices(mealsByDay: MealLogModel.previewWeekMealsByDay))
        self.aiManager = AIManager(service: MockAIService())
        self.pushManager = PushManager(logManager: logManager)
        self.logManager = logManager
        self.reportManager = ReportManager(service: MockReportService(), userManager: userManager)
        self.healthKitManager = HealthKitManager(service: MockHealthService())
        self.bodyMeasurementsManager = BodyMeasurementsManager(services: MockBodyMeasurementServices())
        self.stepsManager = StepsManager(services: MockStepsServices())
        self.goalManager = GoalManager(services: MockGoalServices())
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        self.hkWorkoutManager = hkWorkoutManager
        self.liveActivityManager = LiveActivityManager()
        self.hkWorkoutManager.liveActivityUpdater = liveActivityManager
        #endif
        self.appState = AppState(startingModuleId: isSignedIn ? Constants.tabBarModuleId : Constants.onboardingModuleId)
        self.imageUploadManager = ImageUploadManager(service: MockImageUploadService())
        self.hapticManager = HapticManager()
        self.soundEffectManager = SoundEffectManager()

    }
}
