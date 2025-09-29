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
                .environment(delegate.dependencies.ingredientTemplateManager)
                .environment(delegate.dependencies.recipeTemplateManager)
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.authManager)
                .environment(delegate.dependencies.logManager)
                .environment(delegate.dependencies.reportManager)
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
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            FirebaseApp.configure(options: options)
            Analytics.setAnalyticsCollectionEnabled(true)
        case .prod:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            let providerFactory = MyAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            FirebaseApp.configure(options: options)
            Analytics.setAnalyticsCollectionEnabled(true)
        }
    }
}

@MainActor
struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let exerciseTemplateManager: ExerciseTemplateManager
    let workoutTemplateManager: WorkoutTemplateManager
    let workoutSessionManager: WorkoutSessionManager
    let exerciseHistoryManager: ExerciseHistoryManager
    let ingredientTemplateManager: IngredientTemplateManager
    let recipeTemplateManager: RecipeTemplateManager
    let aiManager: AIManager
    let logManager: LogManager
    let reportManager: ReportManager

    init(config: BuildConfiguration) {
        switch config {
        case .mock(isSignedIn: let isSignedIn):
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
            exerciseTemplateManager = ExerciseTemplateManager(services: MockExerciseTemplateServices())
            workoutTemplateManager = WorkoutTemplateManager(services: MockWorkoutTemplateServices())
            workoutSessionManager = WorkoutSessionManager(services: MockWorkoutSessionServices())
            exerciseHistoryManager = ExerciseHistoryManager(services: MockExerciseHistoryServices())
            ingredientTemplateManager = IngredientTemplateManager(services: MockIngredientTemplateServices())
            recipeTemplateManager = RecipeTemplateManager(services: MockRecipeTemplateServices())
            aiManager = AIManager(service: MockAIService())
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)
            ])
            reportManager = ReportManager(service: MockReportService(), userManager: userManager, logManager: logManager)
            
        case .dev:
            let logs = LogManager(services: [
                ConsoleService(),
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken, loggingEnabled: true),
                FirebaseCrashlyticsService()
            ])
            
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logs)
            userManager = UserManager(services: ProductionUserServices(), logManager: logs)
            exerciseTemplateManager = ExerciseTemplateManager(services: ProductionExerciseTemplateServices())
            workoutTemplateManager = WorkoutTemplateManager(services: ProductionWorkoutTemplateServices())
            workoutSessionManager = WorkoutSessionManager(services: ProductionWorkoutSessionServices())
            exerciseHistoryManager = ExerciseHistoryManager(services: ProductionExerciseHistoryServices())
            ingredientTemplateManager = IngredientTemplateManager(services: ProductionIngredientTemplateServices())
            recipeTemplateManager = RecipeTemplateManager(services: ProductionRecipeTemplateServices())
            aiManager = AIManager(service: GoogleAIService())
            logManager = logs
            reportManager = ReportManager(service: FirebaseReportService(), userManager: userManager, logManager: logs)
            
        case .prod:
            let logs = LogManager(services: [
                ConsoleService(),
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logs)
            userManager = UserManager(services: ProductionUserServices(), logManager: logs)
            exerciseTemplateManager = ExerciseTemplateManager(services: ProductionExerciseTemplateServices())
            workoutTemplateManager = WorkoutTemplateManager(services: ProductionWorkoutTemplateServices())
            workoutSessionManager = WorkoutSessionManager(services: ProductionWorkoutSessionServices())
            exerciseHistoryManager = ExerciseHistoryManager(services: ProductionExerciseHistoryServices())
            ingredientTemplateManager = IngredientTemplateManager(services: ProductionIngredientTemplateServices())
            recipeTemplateManager = RecipeTemplateManager(services: ProductionRecipeTemplateServices())
            aiManager = AIManager(service: GoogleAIService())
            logManager = logs
            reportManager = ReportManager(service: FirebaseReportService(), userManager: userManager, logManager: logs)
        }
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(AppState())
            .environment(LogManager(services: []))
            .environment(ReportManager(service: MockReportService(), userManager: UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))))
            .environment(ExerciseTemplateManager(services: MockExerciseTemplateServices()))
            .environment(WorkoutTemplateManager(services: MockWorkoutTemplateServices()))
            .environment(WorkoutSessionManager(services: MockWorkoutSessionServices()))
            .environment(ExerciseHistoryManager(services: MockExerciseHistoryServices()))
            .environment(IngredientTemplateManager(services: MockIngredientTemplateServices()))
            .environment(RecipeTemplateManager(services: MockRecipeTemplateServices()))
            .environment(AIManager(service: MockAIService()))
    }
}
