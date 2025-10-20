//
//  DialedInApp.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/08/2025.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAnalytics
import FirebaseAppCheck
import GoogleSignIn

@main
struct DialedInApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.exerciseTemplateManager)
                .environment(delegate.dependencies.exerciseUnitPreferenceManager)
                .environment(delegate.dependencies.workoutTemplateManager)
                .environment(delegate.dependencies.workoutSessionManager)
                .environment(delegate.dependencies.exerciseHistoryManager)
                .environment(delegate.dependencies.trainingPlanManager)
                .environment(delegate.dependencies.programTemplateManager)
                .environment(delegate.dependencies.detailNavigationModel)
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                .environment(delegate.dependencies.hkWorkoutManager)
                .environment(delegate.dependencies.workoutActivityViewModel)
                #endif
                .environment(delegate.dependencies.userWeightManager)
                .environment(delegate.dependencies.goalManager)
                .environment(delegate.dependencies.ingredientTemplateManager)
                .environment(delegate.dependencies.recipeTemplateManager)
                .environment(delegate.dependencies.nutritionManager)
                .environment(delegate.dependencies.mealLogManager)
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.logManager)
                .environment(delegate.dependencies.reportManager)
                .environment(delegate.dependencies.healthKitManager)
                .environment(delegate.dependencies.pushManager)
                .environment(delegate.dependencies.purchaseManager)
                .environment(delegate.dependencies.trainingAnalyticsManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.authManager)
                .onOpenURL { url in
                    _ = GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        let config: BuildConfiguration
        
        #if MOCK
        config = .mock(isSignedIn: true)
        #elseif DEBUG
        config = .dev
        #else
        config = .prod
        #endif
        
        config.configure()
        dependencies = Dependencies(config: config)
        return true
    }
    
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool), dev, prod
    
    func configure() {
        switch self {
        case .mock:
            // Mock build does not run Firebase
            break
        case .dev:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            let providerFactory = MyAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            FirebaseApp.configure(options: options)
            Analytics.setAnalyticsCollectionEnabled(true)
            
            // Configure Google Sign-In
            guard let clientId = options.clientID else { fatalError("No client ID found in Firebase options") }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        case .prod:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            let providerFactory = MyAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            FirebaseApp.configure(options: options)
            Analytics.setAnalyticsCollectionEnabled(true)
            
            // Configure Google Sign-In
            guard let clientId = options.clientID else { fatalError("No client ID found in Firebase options") }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        }
    }
}

@MainActor
struct Dependencies {
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
    let workoutActivityViewModel: WorkoutActivityViewModel
    #endif

    // swiftlint:disable:next function_body_length
    init(config: BuildConfiguration) {
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
            workoutActivityViewModel = WorkoutActivityViewModel(hkWorkoutManager: hkWorkoutManager)
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
            trainingPlanManager = TrainingPlanManager(services: ProductionTrainingPlanServices())
            programTemplateManager = ProgramTemplateManager(services: ProgramTemplateServices(local: MockProgramTemplatePersistence(), remote: FirebaseProgramTemplateService()))
            
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
            workoutActivityViewModel = WorkoutActivityViewModel(hkWorkoutManager: hkWorkoutManager)
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
            trainingPlanManager = TrainingPlanManager(services: ProductionTrainingPlanServices())
            programTemplateManager = ProgramTemplateManager(services: ProgramTemplateServices(local: MockProgramTemplatePersistence(), remote: FirebaseProgramTemplateService()))
            
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
            workoutActivityViewModel = WorkoutActivityViewModel(hkWorkoutManager: hkWorkoutManager)
            #endif
        }
        detailNavigationModel = DetailNavigationModel()
        pushManager = PushManager(services: ProductionPushServices(), logManager: logManager)
        healthKitManager = HealthKitManager(service: HealthKitService())
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        let logManager = LogManager(services: [ConsoleService(printParameters: false)])
        let userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        let hkWorkoutManager = HKWorkoutManager()
        #endif
        
        return self
            .environment(userManager)
            .environment(logManager)
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logManager: logManager))
            .environment(AppState())
            .environment(DetailNavigationModel())
            .environment(ReportManager(service: MockReportService(), userManager: userManager))
            .environment(ExerciseTemplateManager(services: MockExerciseTemplateServices()))
            .environment(ExerciseUnitPreferenceManager(userManager: userManager))
            .environment(WorkoutTemplateManager(services: MockWorkoutTemplateServices(), exerciseManager: ExerciseTemplateManager(services: MockExerciseTemplateServices())))
            .environment(WorkoutSessionManager(services: MockWorkoutSessionServices()))
            .environment(ExerciseHistoryManager(services: MockExerciseHistoryServices()))
            .environment(TrainingPlanManager(services: MockTrainingPlanServices()))
            .environment(ProgramTemplateManager(services: ProgramTemplateServices(local: MockProgramTemplatePersistence(), remote: MockProgramTemplateService())))
            .environment(TrainingAnalyticsManager(services: MockTrainingAnalyticsServices()))
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            .environment(hkWorkoutManager)
            .environment(WorkoutActivityViewModel(hkWorkoutManager: hkWorkoutManager))
            #endif
            .environment(UserWeightManager(services: MockUserWeightServices()))
            .environment(GoalManager(services: MockGoalServices()))
            .environment(PurchaseManager(services: MockPurchaseServices()))
            .environment(IngredientTemplateManager(services: MockIngredientTemplateServices()))
            .environment(RecipeTemplateManager(services: MockRecipeTemplateServices()))
            .environment(NutritionManager(services: MockNutritionServices()))
            .environment(MealLogManager(services: MockMealLogServices(mealsByDay: MealLogModel.previewWeekMealsByDay)))
            .environment(AIManager(service: MockAIService()))
            .environment(PushManager(services: MockPushServices(), logManager: nil))
            .environment(HealthKitManager(service: MockHealthService()))
    }
}

@MainActor
class DevPreview {
    static let shared = DevPreview()
    
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
    let workoutActivityViewModel: WorkoutActivityViewModel
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
        self.workoutActivityViewModel = WorkoutActivityViewModel(hkWorkoutManager: hkWorkoutManager)
        #endif
    }
}
