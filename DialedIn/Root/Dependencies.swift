//
//  Dependencies.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@MainActor
struct Dependencies {
    let container: DependencyContainer
    let logManager: LogManager

    // swiftlint:disable:next function_body_length
    init(config: BuildConfiguration) {
        
        let authManager: AuthManager
        let userManager: UserManager
        let purchaseManager: PurchaseManager
        let exerciseTemplateManager: ExerciseTemplateManager
        let exerciseUnitPreferenceManager: ExerciseUnitPreferenceManager
        let workoutTemplateManager: WorkoutTemplateManager
        let workoutSessionManager: WorkoutSessionManager
        let exerciseHistoryManager: ExerciseHistoryManager
        let trainingPlanManager: TrainingPlanManager
        let programTemplateManager: ProgramTemplateManager
        let ingredientTemplateManager: IngredientTemplateManager
        let recipeTemplateManager: RecipeTemplateManager
        let nutritionManager: NutritionManager
        let mealLogManager: MealLogManager
        let pushManager: PushManager
        let aiManager: AIManager
        
        let reportManager: ReportManager
        let healthKitManager: HealthKitManager
        let trainingAnalyticsManager: TrainingAnalyticsManager
        let detailNavigationModel: DetailNavigationModel
        let userWeightManager: UserWeightManager
        let goalManager: GoalManager
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        let hkWorkoutManager: HKWorkoutManager
        let liveActivityManager: LiveActivityManager
        #endif
        
        switch config {
        case .mock(isSignedIn: let isSignedIn):
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
            purchaseManager = PurchaseManager(services: MockPurchaseServices())
            exerciseTemplateManager = ExerciseTemplateManager(services: MockExerciseTemplateServices())
            exerciseUnitPreferenceManager = ExerciseUnitPreferenceManager(userManager: userManager)
            workoutTemplateManager = WorkoutTemplateManager(services: MockWorkoutTemplateServices(), exerciseManager: exerciseTemplateManager)
            workoutSessionManager = WorkoutSessionManager(services: MockWorkoutSessionServices())
            exerciseHistoryManager = ExerciseHistoryManager(services: MockExerciseHistoryServices())
            trainingPlanManager = TrainingPlanManager(services: MockTrainingPlanServices())
            programTemplateManager = ProgramTemplateManager(services: ProgramTemplateServices(local: MockProgramTemplatePersistence(), remote: MockProgramTemplateService()))
            
            // Link managers for auto-completion
            workoutSessionManager.trainingPlanManager = trainingPlanManager
            
            ingredientTemplateManager = IngredientTemplateManager(services: MockIngredientTemplateServices())
            recipeTemplateManager = RecipeTemplateManager(services: MockRecipeTemplateServices())
            nutritionManager = NutritionManager(services: MockNutritionServices())
            mealLogManager = MealLogManager(services: MockMealLogServices(mealsByDay: MealLogModel.mockWeekMealsByDay))
            aiManager = AIManager(service: MockAIService())
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)
            ])
            reportManager = ReportManager(service: MockReportService(), userManager: userManager, logManager: logManager)
            trainingAnalyticsManager = TrainingAnalyticsManager(services: MockTrainingAnalyticsServices())
            userWeightManager = UserWeightManager(services: MockUserWeightServices())
            goalManager = GoalManager(services: MockGoalServices())
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            hkWorkoutManager = HKWorkoutManager()
            liveActivityManager = LiveActivityManager()
            hkWorkoutManager.liveActivityUpdater = liveActivityManager
            #endif

        case .dev:
            let logs = LogManager(services: [
                ConsoleService(),
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken, loggingEnabled: false),
                FirebaseCrashlyticsService()
            ])
            
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logs)
            userManager = UserManager(services: ProductionUserServices(), logManager: logs)
            purchaseManager = PurchaseManager(services: ProductionPurchaseServices())
            exerciseTemplateManager = ExerciseTemplateManager(services: ProductionExerciseTemplateServices())
            exerciseUnitPreferenceManager = ExerciseUnitPreferenceManager(userManager: userManager)
            workoutTemplateManager = WorkoutTemplateManager(services: ProductionWorkoutTemplateServices(exerciseManager: exerciseTemplateManager), exerciseManager: exerciseTemplateManager)
            workoutSessionManager = WorkoutSessionManager(services: ProductionWorkoutSessionServices(logManager: logs))
            exerciseHistoryManager = ExerciseHistoryManager(services: ProductionExerciseHistoryServices())
            trainingPlanManager = TrainingPlanManager(services: ProductionTrainingPlanServices(), workoutTemplateResolver: workoutTemplateManager)
            programTemplateManager = ProgramTemplateManager(services: ProgramTemplateServices(local: MockProgramTemplatePersistence(), remote: FirebaseProgramTemplateService()), workoutTemplateResolver: workoutTemplateManager)
            
            // Link managers for auto-completion
            workoutSessionManager.trainingPlanManager = trainingPlanManager
            
            ingredientTemplateManager = IngredientTemplateManager(services: ProductionIngredientTemplateServices())
            recipeTemplateManager = RecipeTemplateManager(services: ProductionRecipeTemplateServices())
            nutritionManager = NutritionManager(services: ProductionNutritionServices())
            mealLogManager = MealLogManager(services: ProductionMealLogServices())
            aiManager = AIManager(service: GoogleAIService())
            logManager = logs
            reportManager = ReportManager(service: FirebaseReportService(), userManager: userManager, logManager: logs)
            trainingAnalyticsManager = TrainingAnalyticsManager(services: ProductionTrainingAnalyticsServices(workoutSessionManager: workoutSessionManager, exerciseTemplateManager: exerciseTemplateManager))
            userWeightManager = UserWeightManager(services: ProductionUserWeightServices())
            goalManager = GoalManager(services: ProductionGoalServices())
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            hkWorkoutManager = HKWorkoutManager()
            liveActivityManager = LiveActivityManager()
            hkWorkoutManager.liveActivityUpdater = liveActivityManager
            #endif

        case .prod:
            let logs = LogManager(services: [
                ConsoleService(),
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logs)
            userManager = UserManager(services: ProductionUserServices(), logManager: logs)
            purchaseManager = PurchaseManager(services: ProductionPurchaseServices())
            exerciseTemplateManager = ExerciseTemplateManager(services: ProductionExerciseTemplateServices())
            exerciseUnitPreferenceManager = ExerciseUnitPreferenceManager(userManager: userManager)
            workoutTemplateManager = WorkoutTemplateManager(services: ProductionWorkoutTemplateServices(exerciseManager: exerciseTemplateManager), exerciseManager: exerciseTemplateManager)
            workoutSessionManager = WorkoutSessionManager(services: ProductionWorkoutSessionServices(logManager: logs))
            exerciseHistoryManager = ExerciseHistoryManager(services: ProductionExerciseHistoryServices())
            trainingPlanManager = TrainingPlanManager(services: ProductionTrainingPlanServices(), workoutTemplateResolver: workoutTemplateManager)
            programTemplateManager = ProgramTemplateManager(services: ProgramTemplateServices(local: MockProgramTemplatePersistence(), remote: FirebaseProgramTemplateService()), workoutTemplateResolver: workoutTemplateManager)
            
            // Link managers for auto-completion
            workoutSessionManager.trainingPlanManager = trainingPlanManager
            
            ingredientTemplateManager = IngredientTemplateManager(services: ProductionIngredientTemplateServices())
            recipeTemplateManager = RecipeTemplateManager(services: ProductionRecipeTemplateServices())
            nutritionManager = NutritionManager(services: ProductionNutritionServices())
            mealLogManager = MealLogManager(services: ProductionMealLogServices())
            aiManager = AIManager(service: GoogleAIService())
            logManager = logs
            reportManager = ReportManager(service: FirebaseReportService(), userManager: userManager, logManager: logs)
            trainingAnalyticsManager = TrainingAnalyticsManager(services: ProductionTrainingAnalyticsServices(workoutSessionManager: workoutSessionManager, exerciseTemplateManager: exerciseTemplateManager))
            userWeightManager = UserWeightManager(services: ProductionUserWeightServices())
            goalManager = GoalManager(services: ProductionGoalServices())
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            hkWorkoutManager = HKWorkoutManager()
            liveActivityManager = LiveActivityManager()
            hkWorkoutManager.liveActivityUpdater = liveActivityManager
            #endif
        }
        detailNavigationModel = DetailNavigationModel()
        pushManager = PushManager(services: ProductionPushServices(), logManager: logManager)
        healthKitManager = HealthKitManager(service: HealthKitService())
        
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(ExerciseTemplateManager.self, service: exerciseTemplateManager)
        container.register(ExerciseUnitPreferenceManager.self, service: exerciseUnitPreferenceManager)
        container.register(WorkoutTemplateManager.self, service: workoutTemplateManager)
        container.register(WorkoutSessionManager.self, service: workoutSessionManager)
        container.register(ExerciseHistoryManager.self, service: exerciseHistoryManager)
        container.register(TrainingPlanManager.self, service: trainingPlanManager)
        container.register(ProgramTemplateManager.self, service: programTemplateManager)
        container.register(IngredientTemplateManager.self, service: ingredientTemplateManager)
        container.register(RecipeTemplateManager.self, service: recipeTemplateManager)
        container.register(NutritionManager.self, service: nutritionManager)
        container.register(MealLogManager.self, service: mealLogManager)
        container.register(PushManager.self, service: pushManager)
        container.register(AIManager.self, service: aiManager)
        container.register(LogManager.self, service: logManager)
        container.register(ReportManager.self, service: reportManager)
        container.register(HealthKitManager.self, service: healthKitManager)
        container.register(TrainingAnalyticsManager.self, service: trainingAnalyticsManager)
        container.register(DetailNavigationModel.self, service: detailNavigationModel)
        container.register(UserWeightManager.self, service: userWeightManager)
        container.register(GoalManager.self, service: goalManager)
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        container.register(HKWorkoutManager.self, service: hkWorkoutManager)
        container.register(LiveActivityManager.self, service: liveActivityManager)
        #endif
        self.container = container
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        return self
            .environment(LogManager(services: [ConsoleService(printParameters: false)]))
    }
}

@MainActor
class DevPreview {
    static let shared = DevPreview()
    
    var container: DependencyContainer {
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(ExerciseTemplateManager.self, service: exerciseTemplateManager)
        container.register(ExerciseUnitPreferenceManager.self, service: exerciseUnitPreferenceManager)
        container.register(WorkoutTemplateManager.self, service: workoutTemplateManager)
        container.register(WorkoutSessionManager.self, service: workoutSessionManager)
        container.register(ExerciseHistoryManager.self, service: exerciseHistoryManager)
        container.register(TrainingPlanManager.self, service: trainingPlanManager)
        container.register(ProgramTemplateManager.self, service: programTemplateManager)
        container.register(IngredientTemplateManager.self, service: ingredientTemplateManager)
        container.register(RecipeTemplateManager.self, service: recipeTemplateManager)
        container.register(NutritionManager.self, service: nutritionManager)
        container.register(MealLogManager.self, service: mealLogManager)
        container.register(PushManager.self, service: pushManager)
        container.register(AIManager.self, service: aiManager)
        container.register(LogManager.self, service: logManager)
        container.register(ReportManager.self, service: reportManager)
        container.register(HealthKitManager.self, service: healthKitManager)
        container.register(TrainingAnalyticsManager.self, service: trainingAnalyticsManager)
        container.register(DetailNavigationModel.self, service: detailNavigationModel)
        container.register(UserWeightManager.self, service: userWeightManager)
        container.register(GoalManager.self, service: goalManager)
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        container.register(HKWorkoutManager.self, service: hkWorkoutManager)
        container.register(LiveActivityManager.self, service: liveActivityManager)
        #endif
        return container
    }
    
    let authManager: AuthManager
    let userManager: UserManager
    let purchaseManager: PurchaseManager
    let exerciseTemplateManager: ExerciseTemplateManager
    let exerciseUnitPreferenceManager: ExerciseUnitPreferenceManager
    let workoutTemplateManager: WorkoutTemplateManager
    let workoutSessionManager: WorkoutSessionManager
    let exerciseHistoryManager: ExerciseHistoryManager
    let trainingPlanManager: TrainingPlanManager
    let programTemplateManager: ProgramTemplateManager
    let ingredientTemplateManager: IngredientTemplateManager
    let recipeTemplateManager: RecipeTemplateManager
    let nutritionManager: NutritionManager
    let mealLogManager: MealLogManager
    let pushManager: PushManager
    let aiManager: AIManager
    let logManager: LogManager
    let reportManager: ReportManager
    let healthKitManager: HealthKitManager
    let trainingAnalyticsManager: TrainingAnalyticsManager
    let detailNavigationModel: DetailNavigationModel
    let userWeightManager: UserWeightManager
    let goalManager: GoalManager
    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
    let hkWorkoutManager: HKWorkoutManager
    let liveActivityManager: LiveActivityManager
    #endif
    
    init(isSignedIn: Bool = true) {
        let logManager = LogManager(services: [ConsoleService(printParameters: true)])
        let userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        let hkWorkoutManager = HKWorkoutManager()
        #endif
        
        self.authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logManager: logManager)
        self.userManager = userManager
        self.purchaseManager = PurchaseManager(services: MockPurchaseServices())
        self.exerciseTemplateManager = ExerciseTemplateManager(services: MockExerciseTemplateServices())
        self.exerciseUnitPreferenceManager = ExerciseUnitPreferenceManager(userManager: userManager)
        self.workoutTemplateManager = WorkoutTemplateManager(services: MockWorkoutTemplateServices(), exerciseManager: ExerciseTemplateManager(services: MockExerciseTemplateServices()))
        self.workoutSessionManager = WorkoutSessionManager(services: MockWorkoutSessionServices())
        self.exerciseHistoryManager = ExerciseHistoryManager(services: MockExerciseHistoryServices())
        self.trainingPlanManager = TrainingPlanManager(services: MockTrainingPlanServices())
        self.programTemplateManager = ProgramTemplateManager(services: ProgramTemplateServices(local: MockProgramTemplatePersistence(), remote: MockProgramTemplateService()))
        self.ingredientTemplateManager = IngredientTemplateManager(services: MockIngredientTemplateServices())
        self.recipeTemplateManager = RecipeTemplateManager(services: MockRecipeTemplateServices())
        self.nutritionManager = NutritionManager(services: MockNutritionServices())
        self.mealLogManager = MealLogManager(services: MockMealLogServices(mealsByDay: MealLogModel.previewWeekMealsByDay))
        self.aiManager = AIManager(service: MockAIService())
        self.pushManager = PushManager(services: MockPushServices(), logManager: logManager)
        self.logManager = logManager
        self.reportManager = ReportManager(service: MockReportService(), userManager: userManager)
        self.healthKitManager = HealthKitManager(service: MockHealthService())
        self.trainingAnalyticsManager = TrainingAnalyticsManager(services: MockTrainingAnalyticsServices())
        self.detailNavigationModel = DetailNavigationModel()
        self.userWeightManager = UserWeightManager(services: MockUserWeightServices())
        self.goalManager = GoalManager(services: MockGoalServices())
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        self.hkWorkoutManager = hkWorkoutManager
        self.liveActivityManager = LiveActivityManager()
        self.hkWorkoutManager.liveActivityUpdater = liveActivityManager
        #endif
    }
}
