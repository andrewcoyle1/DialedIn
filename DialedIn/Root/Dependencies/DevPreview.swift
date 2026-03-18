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
        container.register(FoodLogSettingsManager.self, service: foodLogSettingsManager)
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
        container.register(ExerciseSettingsManager.self, service: exerciseSettingsManager)
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
    let exerciseSettingsManager: ExerciseSettingsManager
    let foodLogSettingsManager: FoodLogSettingsManager
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
        let userManager = UserManager(queryService: MockUserQueryService(), userSyncEngine: userSyncEngine, followingUsersSyncEngine: followingUsersSyncEngine)
        
        self.authManager = AuthManager(service: MockAuthService(scenario: isSignedIn ? .existingSignedIn : .newAnonymous), logger: logManager)
        self.userManager = userManager
        self.abTestManager = ABTestManager(service: MockABTestService(), logger: logManager)
        self.purchaseManager = PurchaseManager(service: MockPurchaseService())
        let userExerciseSyncEngine = CollectionSyncEngine<ExerciseModel>(
            remote: MockRemoteCollectionService(collection: ExerciseModel.mocks),
            managerKey: Keys.userExerciseManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        let systemExercisePersistence = MockLocalCollectionPersistence(collection: ExerciseModel.mocks)
        self.exerciseModelManager = ExerciseModelManager(userExerciseSyncEngine: userExerciseSyncEngine, systemExercisePersistence: systemExercisePersistence)
        self.exerciseUnitPreferenceManager = ExerciseUnitPreferenceManager(userManager: userManager)
        let workoutSettingsSyncEngine = DocumentSyncEngine<WorkoutSettings>(
            remote: MockRemoteDocumentService(document: WorkoutSettings.mock),
            managerKey: Keys.workoutSettingsManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        self.workoutSettingsManager = WorkoutSettingsManager(workoutSettingsSyncEngine: workoutSettingsSyncEngine)
        let foodLogSettingsSyncEngine = DocumentSyncEngine<FoodLogSettings>(
            remote: MockRemoteDocumentService(document: FoodLogSettings.mock),
            managerKey: Keys.foodLogSettingsManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        self.foodLogSettingsManager = FoodLogSettingsManager(foodLogSettingsSyncEngine: foodLogSettingsSyncEngine)
        let userWorkoutTemplateSyncEngine = CollectionSyncEngine<WorkoutTemplateModel>(
            remote: MockRemoteCollectionService(collection: WorkoutTemplateModel.mocks),
            managerKey: Keys.workoutTemplateManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        let systemWorkoutTemplatePersistence = MockLocalCollectionPersistence<WorkoutTemplateModel>(collection: WorkoutTemplateModel.mocks)
        workoutTemplateManager = WorkoutTemplateManager(userWorkoutTemplateSyncEngine: userWorkoutTemplateSyncEngine, systemWorkoutTemplatePersistence: systemWorkoutTemplatePersistence)
        let activeWorkoutSessionPersistence = MockLocalDocumentPersistence<WorkoutSessionModel>(document: WorkoutSessionModel.mock)
        let userWorkoutSessionSyncEngine = CollectionSyncEngine<WorkoutSessionModel>(
            remote: MockRemoteCollectionService(collection: WorkoutSessionModel.mocks),
            managerKey: Keys.userWorkoutSessionManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        let followingWorkoutSessionSyncEngine = CollectionGroupSyncEngine<WorkoutSessionModel>(
            remote: MockRemoteCollectionGroupService(collection: WorkoutSessionModel.mocks),
            managerKey: Keys.followingWorkoutSessionsManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        workoutSessionManager = WorkoutSessionManager(
            likeService: MockWorkoutSessionLikeService(),
            activeWorkoutSessionPersistence: activeWorkoutSessionPersistence,
            userWorkoutSessionSyncEngine: userWorkoutSessionSyncEngine,
            followingWorkoutSessionSyncEngine: followingWorkoutSessionSyncEngine
        )
        let trainingProgramSyncEngine = CollectionSyncEngine<TrainingProgram>(
            remote: MockRemoteCollectionService(collection: TrainingProgram.mocks),
            managerKey: Keys.trainingProgramManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        self.trainingProgramManager = TrainingProgramManager(trainingProgramSyncEngine: trainingProgramSyncEngine, logManager: logManager)
        let gymProfileSyncEngine = CollectionSyncEngine<GymProfileModel>(
            remote: MockRemoteCollectionService(collection: GymProfileModel.mocks),
            managerKey: Keys.gymProfileManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        gymProfileManager = GymProfileManager(gymProfileSyncEngine: gymProfileSyncEngine)

        let foodSyncEngine = CollectionSyncEngine<FoodModel>(
            remote: MockRemoteCollectionService(collection: FoodModel.mocks),
            managerKey: Keys.foodManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        self.foodManager = FoodManager(foodSyncEngine: foodSyncEngine)
        let userRecipeTemplateSyncEngine = CollectionSyncEngine<RecipeTemplateModel>(
            remote: MockRemoteCollectionService(collection: RecipeTemplateModel.mocks),
            managerKey: Keys.recipeTemplateManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        self.recipeTemplateManager = RecipeTemplateManager(userRecipeTemplateSyncEngine: userRecipeTemplateSyncEngine)
        let dietPlanSyncEngine = DocumentSyncEngine<DietPlan>(
            remote: MockRemoteDocumentService(document: DietPlan.mock),
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
        
        let exerciseSettingsSyncEngineMock = CollectionSyncEngine<ExerciseSettingsModel>(
            remote: MockRemoteCollectionService(collection: []),
            managerKey: Keys.exerciseSettingsManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        self.exerciseSettingsManager = ExerciseSettingsManager(syncEngine: exerciseSettingsSyncEngineMock)
        self.aiManager = AIManager(service: MockAIService())
        self.pushManager = PushManager(logManager: logManager)
        self.logManager = logManager
        self.reportManager = ReportManager(service: MockReportService(), userManager: userManager)
        self.healthKitManager = HealthKitManager(service: MockHealthService())
        let bodyMeasurementsSyncEngine = CollectionSyncEngine<BodyMeasurementEntry>(
            remote: MockRemoteCollectionService(collection: BodyMeasurementEntry.mocks),
            managerKey: Keys.bodyMeasurementsManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        bodyMeasurementsManager = BodyMeasurementsManager(
            bodyMeasurementsSyncEngine: bodyMeasurementsSyncEngine,
            healthKitService: ProductionHealthKitWeightService()
        )
        let stepsSyncEngine = CollectionSyncEngine<StepsModel>(
            remote: MockRemoteCollectionService(collection: StepsModel.mocks),
            managerKey: Keys.stepsManagerKey,
            enableLocalPersistence: true,
            logger: logManager
        )
        stepsManager = StepsManager(stepsSyncEngine: stepsSyncEngine, healthKitService: MockHealthKitStepsService())
        let userGoalSyncEngine = DocumentSyncEngine<WeightGoal>(
            remote: MockRemoteDocumentService(document: WeightGoal.mock()),
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
        hkWorkoutManager = HKWorkoutManager(logger: logManager, liveActivityUpdater: liveActivityManager)
        #endif

        self.appState = AppState(startingModuleId: isSignedIn ? Constants.tabBarModuleId : Constants.onboardingModuleId)
        self.imageUploadManager = ImageUploadManager(service: MockImageUploadService())
        self.commentsManager = CommentsManager(service: MockCommentsService())
        self.activityNotificationManager = ActivityNotificationManager(service: MockActivityNotificationService())
        self.stravaManager = StravaManager(service: MockStravaService(), clientId: "", clientSecret: "")
        self.hapticManager = HapticManager()
        self.soundEffectManager = SoundEffectManager()

        if isSignedIn {
            Task { @MainActor in
                let mockUser = UserAuthInfo.mock(isAnonymous: false)
                try? await userManager.signIn(auth: mockUser, isNewUser: false)
                async let workoutSettingsSignIn: () = workoutSettingsManager.signIn(userId: mockUser.uid)
                async let exerciseSettingsSignIn: () = exerciseSettingsManager.signIn(userId: mockUser.uid)
                async let foodLogSettingsSignIn: () = foodLogSettingsManager.signIn(userId: mockUser.uid)
                async let stepsSignIn: () = stepsManager.signIn()
                async let workoutTemplatesSignIn: () = workoutTemplateManager.signIn()
                async let gymProfileSignIn: () = gymProfileManager.signIn()
                async let trainingProgramSignIn: () = trainingProgramManager.signIn(userId: mockUser.uid)
                async let workoutSessionSignIn: () = workoutSessionManager.signIn(userId: mockUser.uid)
                async let exerciseSignIn: () = exerciseModelManager.signIn(userId: mockUser.uid)
                async let recipeTemplatesSignIn: () = recipeTemplateManager.signIn()
                async let foodsSignIn: () = foodManager.signIn()
                async let nutritionSignIn: () = nutritionManager.signIn(dietPlanId: mockUser.uid)
                async let mealLogSignIn: () = mealLogManager.signIn(userId: mockUser.uid)
                async let bodyMeasurementsSignIn: () = bodyMeasurementsManager.signIn(userId: mockUser.uid)
                async let goalSignIn: () = goalManager.signIn(userId: mockUser.uid)
                try? await workoutSettingsSignIn
                await exerciseSettingsSignIn
                try? await foodLogSettingsSignIn
                await stepsSignIn
                await workoutTemplatesSignIn
                await gymProfileSignIn
                await trainingProgramSignIn
                await workoutSessionSignIn
                await exerciseSignIn
                await recipeTemplatesSignIn
                await foodsSignIn
                try? await nutritionSignIn
                await mealLogSignIn
                await bodyMeasurementsSignIn
                try? await goalSignIn
            }
        }
    }
}
