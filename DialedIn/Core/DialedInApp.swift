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
                .environment(delegate.dependencies.workoutTemplateManager)
                .environment(delegate.dependencies.workoutSessionManager)
                .environment(delegate.dependencies.exerciseHistoryManager)
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                .environment(delegate.dependencies.hkWorkoutManager)
                .environment(delegate.dependencies.workoutActivityViewModel)
                #endif
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
    let workoutTemplateManager: WorkoutTemplateManager
    let workoutSessionManager: WorkoutSessionManager
    let exerciseHistoryManager: ExerciseHistoryManager
    let trainingPlanManager: TrainingPlanManager
    let ingredientTemplateManager: IngredientTemplateManager
    let recipeTemplateManager: RecipeTemplateManager
    let nutritionManager: NutritionManager
    let mealLogManager: MealLogManager
    let pushManager: PushManager
    let aiManager: AIManager
    let logManager: LogManager
    let reportManager: ReportManager
    let healthKitManager: HealthKitManager
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
            workoutTemplateManager = WorkoutTemplateManager(services: MockWorkoutTemplateServices())
            workoutSessionManager = WorkoutSessionManager(services: MockWorkoutSessionServices())
            exerciseHistoryManager = ExerciseHistoryManager(services: MockExerciseHistoryServices())
            trainingPlanManager = TrainingPlanManager(services: MockTrainingPlanServices())
            ingredientTemplateManager = IngredientTemplateManager(services: MockIngredientTemplateServices())
            recipeTemplateManager = RecipeTemplateManager(services: MockRecipeTemplateServices())
            nutritionManager = NutritionManager(services: MockNutritionServices())
            mealLogManager = MealLogManager(services: MockMealLogServices(mealsByDay: MealLogModel.mockWeekMealsByDay))
            aiManager = AIManager(service: MockAIService())
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)
            ])
            reportManager = ReportManager(service: MockReportService(), userManager: userManager, logManager: logManager)
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
            workoutTemplateManager = WorkoutTemplateManager(services: ProductionWorkoutTemplateServices())
            workoutSessionManager = WorkoutSessionManager(services: ProductionWorkoutSessionServices())
            exerciseHistoryManager = ExerciseHistoryManager(services: ProductionExerciseHistoryServices())
            trainingPlanManager = TrainingPlanManager(services: ProductionTrainingPlanServices())
            ingredientTemplateManager = IngredientTemplateManager(services: ProductionIngredientTemplateServices())
            recipeTemplateManager = RecipeTemplateManager(services: ProductionRecipeTemplateServices())
            nutritionManager = NutritionManager(services: ProductionNutritionServices())
            mealLogManager = MealLogManager(services: ProductionMealLogServices())
            aiManager = AIManager(service: GoogleAIService())
            logManager = logs
            reportManager = ReportManager(service: FirebaseReportService(), userManager: userManager, logManager: logs)
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
            workoutTemplateManager = WorkoutTemplateManager(services: ProductionWorkoutTemplateServices())
            workoutSessionManager = WorkoutSessionManager(services: ProductionWorkoutSessionServices())
            exerciseHistoryManager = ExerciseHistoryManager(services: ProductionExerciseHistoryServices())
            trainingPlanManager = TrainingPlanManager(services: ProductionTrainingPlanServices())
            ingredientTemplateManager = IngredientTemplateManager(services: ProductionIngredientTemplateServices())
            recipeTemplateManager = RecipeTemplateManager(services: ProductionRecipeTemplateServices())
            nutritionManager = NutritionManager(services: ProductionNutritionServices())
            mealLogManager = MealLogManager(services: ProductionMealLogServices())
            aiManager = AIManager(service: GoogleAIService())
            logManager = logs
            reportManager = ReportManager(service: FirebaseReportService(), userManager: userManager, logManager: logs)
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            hkWorkoutManager = HKWorkoutManager()
            workoutActivityViewModel = WorkoutActivityViewModel(hkWorkoutManager: hkWorkoutManager)
            #endif
        }
        pushManager = PushManager(services: ProductionPushServices(), logManager: logManager)
        healthKitManager = HealthKitManager(service: HealthKitService())
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        let logManager = LogManager(services: [ConsoleService(printParameters: false)])
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        let hkWorkoutManager = HKWorkoutManager()
        #endif
        
        return self
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(logManager)
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logManager: logManager))
            .environment(AppState())
            .environment(ReportManager(service: MockReportService(), userManager: UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))))
            .environment(ExerciseTemplateManager(services: MockExerciseTemplateServices()))
            .environment(WorkoutTemplateManager(services: MockWorkoutTemplateServices()))
            .environment(WorkoutSessionManager(services: MockWorkoutSessionServices()))
            .environment(ExerciseHistoryManager(services: MockExerciseHistoryServices()))
            .environment(TrainingPlanManager(services: MockTrainingPlanServices()))
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            .environment(hkWorkoutManager)
            .environment(WorkoutActivityViewModel(hkWorkoutManager: hkWorkoutManager))
            #endif
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
