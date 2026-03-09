//
//  DevPreview.swift
//  DialedIn
//
//  Created by Andrew Coyle on 09/03/2026.
//

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
        container.register(FoodManager.self, service: foodManager)
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
        container.register(ActivityNotificationManager.self, service: activityNotificationManager)
        container.register(StravaManager.self, service: stravaManager)
        container.register(OpenFoodFactsServiceContainer.self, service: OpenFoodFactsServiceContainer(openFoodFactsService))

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
    let foodManager: FoodManager
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
    let activityNotificationManager: ActivityNotificationManager
    let stravaManager: StravaManager
    let openFoodFactsService: any OpenFoodFactsService = MockOpenFoodFactsService()

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

        let foodSyncEngine = CollectionSyncEngine<FoodModel>(
            remote: MockRemoteCollectionService(),
            managerKey: Keys.foodManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        self.foodManager = FoodManager(foodSyncEngine: foodSyncEngine)
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
        self.activityNotificationManager = ActivityNotificationManager(service: MockActivityNotificationService())
        self.stravaManager = StravaManager(service: MockStravaService(), clientId: "", clientSecret: "")
        self.hapticManager = HapticManager()
        self.soundEffectManager = SoundEffectManager()

    }
}
