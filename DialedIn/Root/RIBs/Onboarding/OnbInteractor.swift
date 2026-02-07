//
//  OnbInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import Foundation

struct OnbInteractor {
    private let gIDClientID: String
    private let authManager: AuthManager
    private let userManager: UserManager
    private let abTestManager: ABTestManager
    private let purchaseManager: PurchaseManager
    private let workoutSessionManager: WorkoutSessionManager
    private let exerciseTemplateManager: ExerciseTemplateManager
    private let workoutTemplateManager: WorkoutTemplateManager
    private let trainingPlanManager: TrainingPlanManager
    private let programTemplateManager: ProgramTemplateManager
    private let nutritionManager: NutritionManager
    private let pushManager: PushManager
    private let goalManager: GoalManager
    private let healthKitManager: HealthKitManager
    private let logManager: LogManager
    private let stepsManager: StepsManager
    private let appState: AppState

    init(container: DependencyContainer) {
        self.gIDClientID = container.resolve(GoogleSignInConfig.self)!.clientID
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.nutritionManager = container.resolve(NutritionManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.programTemplateManager = container.resolve(ProgramTemplateManager.self)!
        self.appState = container.resolve(AppState.self)!
        self.healthKitManager = container.resolve(HealthKitManager.self)!
        self.goalManager = container.resolve(GoalManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.stepsManager = container.resolve(StepsManager.self)!
    }
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    var onboardingStep: OnboardingStep {
        userManager.currentUser?.onboardingStep ?? .auth
    }
    
    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func signInApple() async throws -> (UserAuthInfo, Bool) {
        try await authManager.signInApple()
    }
    
    func signInGoogle() async throws -> (UserAuthInfo, Bool) {
        try await authManager.signInGoogle(GIDClientID: gIDClientID)
    }
    
    func logIn(auth: UserAuthInfo, image: PlatformImage? = nil, isNewUser: Bool) async throws {
        // Reuse shared login that persists the user profile for new accounts and logs into purchases
        try await logIn(user: auth, isNewUser: isNewUser)
        
        // Start the sync listener for training plans
        trainingPlanManager.startSyncListener(userId: auth.uid)
    }

    func updateAppState(showTabBarView: Bool) {
        appState.updateViewState(showTabBarView: showTabBarView)
    }
    
    var activeTests: ActiveABTests {
        abTestManager.activeTests
    }

    func override(updatedTests: ActiveABTests) throws {
        try abTestManager.override(updatedTests: updatedTests)
    }

    func getBuiltInTemplates() -> [ProgramTemplateModel] {
        programTemplateManager.getBuiltInTemplates()
    }

    func createPlanFromTemplate(
        _ template: ProgramTemplateModel,
        startDate: Date,
        endDate: Date? = nil,
        userId: String,
        planName: String? = nil
    ) async throws -> TrainingPlan {
        try await trainingPlanManager.createPlanFromTemplate(template, startDate: startDate, endDate: endDate, userId: userId, planName: planName)
    }

    func setActivePlan(_ plan: TrainingPlan) {
        trainingPlanManager.setActivePlan(plan)
    }
    
    func createGoal(
        userId: String,
        objective: OverarchingObjective,
        startingWeightKg: Double,
        targetWeightKg: Double,
        weeklyChangeKg: Double
    ) async throws -> WeightGoal {
        try await goalManager.createGoal(userId: userId, objective: objective, startingWeightKg: startingWeightKg, targetWeightKg: targetWeightKg, weeklyChangeKg: weeklyChangeKg)
    }

    func updateOnboardingStep(step: OnboardingStep) async throws {
        try await userManager.updateOnboardingStep(step: step)
    }

    func updateCurrentGoalId(goalId: String?) async throws {
        try await userManager.updateCurrentGoalId(goalId: goalId)
    }
    
    var auth: UserAuthInfo? {
        authManager.auth
    }

    var currentTrainingPlan: TrainingPlan? {
        trainingPlanManager.currentTrainingPlan
    }

    var activeSession: WorkoutSessionModel? {
        workoutSessionManager.activeSession
    }

    func getAllLocalExerciseTemplates() throws -> [ExerciseModel] {
        try exerciseTemplateManager.getAllLocalExerciseTemplates()
    }

    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel] {
        try workoutTemplateManager.getAllLocalWorkoutTemplates()
    }

    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel? {
        try workoutSessionManager.getActiveLocalWorkoutSession()
    }

    func getCurrentWeek() -> TrainingWeek? {
        trainingPlanManager.getCurrentWeek()
    }

    func getTodaysWorkouts() -> [ScheduledWorkout] {
        trainingPlanManager.getTodaysWorkouts()
    }

    func getAllLocalWorkoutSessions() throws -> [WorkoutSessionModel] {
        try workoutSessionManager.getAllLocalWorkoutSessions()
    }

    func updatePlan(_ plan: TrainingPlan) async throws {
        try await trainingPlanManager.updatePlan(plan)
    }

    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel {
        try await workoutSessionManager.getWorkoutSession(id: id)
    }

    @MainActor
    func clearAllTrainingPlanLocalData() throws {
        try trainingPlanManager.clearAllLocalData()
    }

    func deleteAllLocalWorkoutSessionsForAuthor(authorId: String) throws {
        try workoutSessionManager.deleteAllLocalWorkoutSessionsForAuthor(authorId: authorId)
    }

    func clearAllLocalStepsData() throws {
        try stepsManager.clearAllLocalStepsData()
    }
    
    var paywallTest: PaywallTestOption {
        activeTests.paywallTest
    }

    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        try await purchaseManager.getProducts(productIds: productIds)
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        try await purchaseManager.restorePurchase()
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        try await purchaseManager.purchaseProduct(productId: productId)
    }

    func saveUser(user: UserModel, image: PlatformImage? = nil) async throws {
        try await userManager.saveUser(user: user, image: image)
    }
    
    // swiftlint:disable:next function_parameter_count
    func saveCompleteAccountSetupProfile(
        dateOfBirth: Date,
        gender: Gender,
        heightCentimeters: Double,
        weightKilograms: Double,
        exerciseFrequency: ProfileExerciseFrequency,
        dailyActivityLevel: ProfileDailyActivityLevel,
        cardioFitnessLevel: ProfileCardioFitnessLevel,
        lengthUnitPreference: LengthUnitPreference,
        weightUnitPreference: WeightUnitPreference,
        onboardingStep: OnboardingStep
    ) async throws -> UserModel {
        try await userManager
            .saveCompleteAccountSetupProfile(
                dateOfBirth: dateOfBirth,
                gender: gender,
                heightCentimeters: heightCentimeters,
                weightKilograms: weightKilograms,
                exerciseFrequency: exerciseFrequency,
                dailyActivityLevel: dailyActivityLevel,
                cardioFitnessLevel: cardioFitnessLevel,
                lengthUnitPreference: lengthUnitPreference,
                weightUnitPreference: weightUnitPreference,
                onboardingStep: onboardingStep
            )
    }

    func saveCompleteAccountSetupProfile(userBuilder: UserModelBuilder, onboardingStep: OnboardingStep) async throws -> UserModel {
        guard let dob = userBuilder.dateOfBirth,
              let height = userBuilder.height,
              let weight = userBuilder.weight,
              let exercise = userBuilder.exerciseFrequency,
              let activity = userBuilder.activityLevel,
              let cardio = userBuilder.cardioFitness,
              let lengthPref = userBuilder.lengthUnitPreference,
              let weightPref = userBuilder.weightUnitPreferene else {
            throw CoreInteractorError.incompleteUserBuilder
        }
        return try await saveCompleteAccountSetupProfile(
            dateOfBirth: dob,
            gender: userBuilder.gender,
            heightCentimeters: height,
            weightKilograms: weight,
            exerciseFrequency: mapProfileExerciseFrequency(exercise),
            dailyActivityLevel: mapProfileActivityLevel(activity),
            cardioFitnessLevel: mapProfileCardioFitness(cardio),
            lengthUnitPreference: lengthPref,
            weightUnitPreference: weightPref,
            onboardingStep: onboardingStep
        )
    }
    
    private func mapProfileExerciseFrequency(_ frequency: ExerciseFrequency) -> ProfileExerciseFrequency {
        ProfileExerciseFrequency(rawValue: frequency.rawValue) ?? .threeToFour
    }

    private func mapProfileActivityLevel(_ activityLevel: ActivityLevel) -> ProfileDailyActivityLevel {
        ProfileDailyActivityLevel(rawValue: activityLevel.rawValue) ?? .moderate
    }
    
    private func mapProfileCardioFitness(_ level: CardioFitnessLevel) -> ProfileCardioFitnessLevel {
        ProfileCardioFitnessLevel(rawValue: level.rawValue) ?? .intermediate
    }

    func estimateTDEE(user: UserModel?) -> Double {
        nutritionManager.estimateTDEE(user: user)
    }

    func canRequestNotificationAuthorisation() async -> Bool {
        await pushManager.canRequestAuthorisation()
    }

    func canRequestHealthDataAuthorisation() -> Bool {
        healthKitManager.canRequestAuthorisation()
    }
    
    func requestPushAuthorisation() async throws -> Bool {
        try await pushManager.requestAuthorisation()
    }

    func requestHealthKitAuthorisation() async throws {
        try await healthKitManager.requestAuthorisation()
    }

    func updateHealthConsents(disclaimerVersion: String, step: OnboardingStep, privacyVersion: String, acceptedAt: Date = Date()) async throws {
        try await userManager.updateHealthConsents(disclaimerVersion: disclaimerVersion, step: step, privacyVersion: privacyVersion, acceptedAt: acceptedAt)
    }
    
    func get(id: String) -> ProgramTemplateModel? {
        programTemplateManager.get(id: id)
    }

    var isPremium: Bool {
        purchaseManager.entitlements.hasActiveEntitlement
    }

    func computeDietPlan(user: UserModel?, builder: DietPlanBuilder) -> DietPlan {
        nutritionManager.computeDietPlan(user: user, builder: builder)
    }

    func saveDietPlan(plan: DietPlan) async throws {
        try await nutritionManager.saveDietPlan(plan: plan)
    }

    // MARK: Shared
    
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.logIn(auth: user, isNewUser: isNewUser)
        try await purchaseManager.logIn(
            userId: user.uid,
            userAttributes: PurchaseProfileAttributes(
                email: user.email,
                mixpanelDistinctId: Constants.mixpanelDistinctId,
                firebaseAppInstanceId: Constants.firebaseAnalyticsAppInstanceID
            )
        )
    }

    func signOut() async throws {
        try authManager.signOut()
        try await purchaseManager.logOut()
        userManager.signOut()
    }
}
