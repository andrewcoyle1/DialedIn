//
//  CoreInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/10/2025.
//

import Foundation
import UserNotifications
import UIKit
import HealthKit
import ActivityKit

enum CoreInteractorError: Error {
    case incompleteUserBuilder
}

@MainActor
// swiftlint:disable:next type_body_length
struct CoreInteractor: GlobalInteractor {
    private let authManager: AuthManager
    private let userManager: UserManager
    private let abTestManager: ABTestManager
    private let purchaseManager: PurchaseManager
    private let exerciseTemplateManager: ExerciseTemplateManager
    private let exerciseUnitPreferenceManager: ExerciseUnitPreferenceManager
    private let workoutTemplateManager: WorkoutTemplateManager
    private let workoutSessionManager: WorkoutSessionManager
    private let exerciseHistoryManager: ExerciseHistoryManager
    private let trainingPlanManager: TrainingPlanManager
    private let programTemplateManager: ProgramTemplateManager
    private let trainingProgramManager: TrainingProgramManager
    private let gymProfileManager: GymProfileManager
    private let ingredientTemplateManager: IngredientTemplateManager
    private let recipeTemplateManager: RecipeTemplateManager
    private let nutritionManager: NutritionManager
    private let mealLogManager: MealLogManager
    private let pushManager: PushManager
    private let aiManager: AIManager
    private let logManager: LogManager
    private let reportManager: ReportManager
    private let healthKitManager: HealthKitManager
    private let healthKitStepService: HealthKitStepService
    private let bodyMeasurementsManager: BodyMeasurementsManager
    private let stepsManager: StepsManager
    private let goalManager: GoalManager
    private let imageUploadManager: ImageUploadManager
    private let gIDClientID: String
#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
    private let hkWorkoutManager: HKWorkoutManager
    private let liveActivityManager: LiveActivityManager
#endif
    private let appState: AppState

    private let hapticManager: HapticManager
    private let soundEffectManager: SoundEffectManager

    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.exerciseUnitPreferenceManager = container.resolve(ExerciseUnitPreferenceManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.exerciseHistoryManager = container.resolve(ExerciseHistoryManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.programTemplateManager = container.resolve(ProgramTemplateManager.self)!
        self.trainingProgramManager = container.resolve(TrainingProgramManager.self)!
        self.gymProfileManager = container.resolve(GymProfileManager.self)!
        self.ingredientTemplateManager = container.resolve(IngredientTemplateManager.self)!
        self.recipeTemplateManager = container.resolve(RecipeTemplateManager.self)!
        self.nutritionManager = container.resolve(NutritionManager.self)!
        self.mealLogManager = container.resolve(MealLogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.reportManager = container.resolve(ReportManager.self)!
        self.healthKitManager = container.resolve(HealthKitManager.self)!
        self.healthKitStepService = container.resolve(HealthKitStepService.self)!
        self.bodyMeasurementsManager = container.resolve(BodyMeasurementsManager.self)!
        self.stepsManager = container.resolve(StepsManager.self)!
        self.goalManager = container.resolve(GoalManager.self)!
        self.imageUploadManager = container.resolve(ImageUploadManager.self)!
        self.gIDClientID = container.resolve(GoogleSignInConfig.self)!.clientID
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        self.hkWorkoutManager = container.resolve(HKWorkoutManager.self)!
        self.liveActivityManager = container.resolve(LiveActivityManager.self)!
        #endif
        self.appState = container.resolve(AppState.self)!

        self.hapticManager = container.resolve(HapticManager.self)!
        self.soundEffectManager = container.resolve(SoundEffectManager.self)!

        _ = try? getActiveTrainingProgram()
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
    
    func deleteAccount() async throws {
        let uid = try authManager.getAuthId()
        try await exerciseTemplateManager.removeAuthorIdFromAllExerciseTemplates(id: uid)
        try await workoutTemplateManager.removeAuthorIdFromAllWorkoutTemplates(id: uid)
        try await workoutSessionManager.deleteAllWorkoutSessionsForAuthor(authorId: uid)
        try await recipeTemplateManager.removeAuthorIdFromAllRecipeTemplates(id: uid)
        try await ingredientTemplateManager.removeAuthorIdFromAllIngredientTemplates(id: uid)
        try await mealLogManager.deleteAllMealLogsForAuthor(authorId: uid)
        try await userManager.deleteCurrentUser()
        try await authManager.deleteAccount()
        try await purchaseManager.logOut()
        logManager.deleteUserProfile()
    }
    
    // MARK: AppState

    func updateAppState(showTabBarView: Bool) {
        appState.updateViewState(showTabBarView: showTabBarView)
    }

    // MARK: AuthManager
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
                
    func reauthenticateApple() async throws {
       _ = try await authManager.signInApple()
    }
    
    func signInGoogle() async throws -> (UserAuthInfo, Bool) {
        try await authManager.signInGoogle(GIDClientID: gIDClientID)
    }
        
    // MARK: UserManager
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    var userId: String? {
        userManager.currentUser?.userId
    }
    
    var onboardingStep: OnboardingStep {
        userManager.currentUser?.onboardingStep ?? .auth
    }
    
    func currentUserId() throws -> String? {
        try userManager.currentUserId()
    }
    
    func refreshProfileImage() async throws {
        try await userManager.refreshProfileImage()
    }

    var userImageUrl: String? {
        currentUser?.profileImageUrl
    }

    func clearAllLocalData() {
        userManager.clearAllLocalData()
    }
    
    func logIn(auth: UserAuthInfo, image: PlatformImage? = nil) async throws {
        try await userManager.logIn(auth: auth, image: image)
        
        // Start the sync listener for training plans
        let userId = try userManager.currentUserId()
        trainingPlanManager.startSyncListener(userId: userId)
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
            
    func updateFirstName(firstName: String) async throws {
        try await userManager.updateFirstName(firstName: firstName)
    }
    
    func updateLastName(lastName: String) async throws {
        try await userManager.updateLastName(lastName: lastName)
    }
    
    func updateDateOfBirth(dob: Date) async throws {
        try await userManager.updateDateOfBirth(dob: dob)
    }
    
    func updateGender(gender: Gender) async throws {
        try await userManager.updateGender(gender: gender)
    }
    
    func updateWeight(userId: String, weightKg: Double) async throws {
        try await userManager.updateWeight(userId: userId, weightKg: weightKg)
    }
    
    // Image URL
    
    func updateProfileImageUrl(url: String?) async throws {
        try await userManager.updateProfileImageUrl(url: url)
    }
    
    // Active Training Program
    
    func updateActiveTrainingProgramId(programId: String?) async throws {
        try await userManager.updateActiveTrainingProgramId(programId: programId)
    }
    
    // Favourite Gym Profile
    
    func updateFavouriteGymProfileId(profileId: String?) async throws {
        try await userManager.updateFavouriteGymProfileId(profileId: profileId)
    }
    
    // Update Metadata
    
    func updateLastSignInDate() async throws {
        try await userManager.updateLastSignInDate()
    }
    
    func updateOnboardingStep(step: OnboardingStep) async throws {
        try await userManager.updateOnboardingStep(step: step)
    }
    
    // Goal Settings
    func updateCurrentGoalId(goalId: String?) async throws {
        try await userManager.updateCurrentGoalId(goalId: goalId)
    }
    
    // Consents
    func updateHealthConsents(disclaimerVersion: String, step: OnboardingStep, privacyVersion: String, acceptedAt: Date = Date()) async throws {
        try await userManager.updateHealthConsents(disclaimerVersion: disclaimerVersion, step: step, privacyVersion: privacyVersion, acceptedAt: acceptedAt)
    }
    
    // User Blocking
    
    func blockUser(userId: String) async throws {
        try await userManager.blockUser(userId: userId)
    }
    
    func unblockUser(userId: String) async throws {
        try await userManager.unblockUser(userId: userId)
    }
    
    // User deletion
    
    /// Orchestrates the complete deletion of all user data.
    /// This includes local and remote workout sessions, exercise history, templates, profile image, and the user profile document.
    func deleteCurrentUser() async throws {
        let uid = try userManager.currentUserId()

        // 1) Delete/anonymize LOCAL data first (best-effort)
        do {
            try workoutSessionManager.deleteAllLocalWorkoutSessionsForAuthor(authorId: uid)
        } catch { /* ignore local errors */ }
        do {
            try exerciseHistoryManager.deleteAllLocalExerciseHistoryForAuthor(authorId: uid)
        } catch { /* ignore local errors */ }

        // 2) Delete/anonymize REMOTE data in parallel while auth is still valid
        try await withThrowingTaskGroup(of: Void.self) { group in
            // Profile image in Storage (best-effort; ignore if missing)
            group.addTask {
                do {
                    try await self.imageUploadManager.deleteImage(path: "users/\(uid)/profile.jpg")
                } catch {
                    /* ignore storage deletion errors */
                }
            }
            // Workout Sessions
            group.addTask {
                try await self.workoutSessionManager.deleteAllWorkoutSessionsForAuthor(authorId: uid)
            }
            // Exercise History
            group.addTask {
                try await self.exerciseHistoryManager.deleteAllExerciseHistoryForAuthor(authorId: uid)
            }
            // Templates: remove author_id to anonymize authored content
            group.addTask {
                try await self.exerciseTemplateManager.removeAuthorIdFromAllExerciseTemplates(id: uid)
            }
            group.addTask {
                try await self.workoutTemplateManager.removeAuthorIdFromAllWorkoutTemplates(id: uid)
            }
            group.addTask {
                try await self.ingredientTemplateManager.removeAuthorIdFromAllIngredientTemplates(id: uid)
            }
            group.addTask {
                try await self.recipeTemplateManager.removeAuthorIdFromAllRecipeTemplates(id: uid)
            }
            try await group.waitForAll()
        }

        // 3) Remove the user profile document and clear local state (handled by UserManager)
        try await userManager.deleteCurrentUser()
    }
    
    // Template Management
    
    func addCreatedExerciseTemplate(exerciseId: String) async throws {
        try await userManager.addCreatedExerciseTemplate(exerciseId: exerciseId)
    }
    
    func removeCreatedExerciseTemplate(exerciseId: String) async throws {
        try await userManager.removeCreatedExerciseTemplate(exerciseId: exerciseId)
    }
    
    func addBookmarkedExerciseTemplate(exerciseId: String) async throws {
        try await userManager.addBookmarkedExerciseTemplate(exerciseId: exerciseId)
    }
    
    func removeBookmarkedExerciseTemplate(exerciseId: String) async throws {
        try await userManager.removeBookmarkedExerciseTemplate(exerciseId: exerciseId)
    }
    
    func addFavouritedExerciseTemplate(exerciseId: String) async throws {
        try await userManager.addFavouritedExerciseTemplate(exerciseId: exerciseId)
    }
    
    func removeFavouritedExerciseTemplate(exerciseId: String) async throws {
        try await userManager.removeFavouritedExerciseTemplate(exerciseId: exerciseId)
    }
    
    // Created/Bookmarked/Favourited Workout Templates
    
    func addCreatedWorkoutTemplate(workoutId: String) async throws {
        try await userManager.addCreatedWorkoutTemplate(workoutId: workoutId)
    }
    
    func removeCreatedWorkoutTemplate(workoutId: String) async throws {
        try await userManager.removeCreatedWorkoutTemplate(workoutId: workoutId)
    }
    
    func addBookmarkedWorkoutTemplate(workoutId: String) async throws {
        try await userManager.addBookmarkedWorkoutTemplate(workoutId: workoutId)
    }
    
    func removeBookmarkedWorkoutTemplate(workoutId: String) async throws {
        try await userManager.removeBookmarkedWorkoutTemplate(workoutId: workoutId)
    }
    
    func addFavouritedWorkoutTemplate(workoutId: String) async throws {
        try await userManager.addFavouritedWorkoutTemplate(workoutId: workoutId)
    }
    
    func removeFavouritedWorkoutTemplate(workoutId: String) async throws {
        try await userManager.removeFavouritedWorkoutTemplate(workoutId: workoutId)
    }
    
    // MARK: - Created/Bookmarked/Favourited Ingredient Templates

    func addCreatedIngredientTemplate(ingredientId: String) async throws {
        try await userManager.addCreatedIngredientTemplate(ingredientId: ingredientId)
    }

    func removeCreatedIngredientTemplate(ingredientId: String) async throws {
        try await userManager.removeCreatedIngredientTemplate(ingredientId: ingredientId)
    }

    func addBookmarkedIngredientTemplate(ingredientId: String) async throws {
        try await userManager.addBookmarkedIngredientTemplate(ingredientId: ingredientId)
    }

    func removeBookmarkedIngredientTemplate(ingredientId: String) async throws {
        try await userManager.removeBookmarkedIngredientTemplate(ingredientId: ingredientId)
    }

    func addFavouritedIngredientTemplate(ingredientId: String) async throws {
        try await userManager.addFavouritedIngredientTemplate(ingredientId: ingredientId)
    }

    func removeFavouritedIngredientTemplate(ingredientId: String) async throws {
        try await userManager.removeFavouritedIngredientTemplate(ingredientId: ingredientId)
    }

    // MARK: - Created/Bookmarked/Favourited Recipe Templates

    func addCreatedRecipeTemplate(recipeId: String) async throws {
        try await userManager.addCreatedRecipeTemplate(recipeId: recipeId)
    }

    func removeCreatedRecipeTemplate(recipeId: String) async throws {
        try await userManager.removeCreatedRecipeTemplate(recipeId: recipeId)
    }

    func addBookmarkedRecipeTemplate(recipeId: String) async throws {
        try await userManager.addBookmarkedRecipeTemplate(recipeId: recipeId)
    }

    func removeBookmarkedRecipeTemplate(recipeId: String) async throws {
        try await userManager.removeBookmarkedRecipeTemplate(recipeId: recipeId)
    }

    func addFavouritedRecipeTemplate(recipeId: String) async throws {
        try await userManager.addFavouritedRecipeTemplate(recipeId: recipeId)
    }

    func removeFavouritedRecipeTemplate(recipeId: String) async throws {
        try await userManager.removeFavouritedRecipeTemplate(recipeId: recipeId)
    }
    
    // MARK: ABTestManager
    
    var activeTests: ActiveABTests {
        abTestManager.activeTests
    }
    
    var paywallTest: PaywallTestOption {
        activeTests.paywallTest
    }

    func override(updatedTests: ActiveABTests) throws {
        try abTestManager.override(updatedTests: updatedTests)
    }
    
    // MARK: PurchaseManager
        
    var entitlements: [PurchasedEntitlement] {
        purchaseManager.entitlements
    }
    
    var isPremium: Bool {
        entitlements.hasActiveEntitlement
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
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        try await purchaseManager.updateProfileAttributes(attributes: attributes)
    }

    // MARK: ExerciseTemplateManager

    func addLocalExerciseTemplate(exercise: ExerciseModel) async throws {
        try await exerciseTemplateManager.addLocalExerciseTemplate(exercise: exercise)
    }
    
    func getLocalExerciseTemplate(id: String) throws -> ExerciseModel {
        try exerciseTemplateManager.getLocalExerciseTemplate(id: id)
    }
    
    func getLocalExerciseTemplates(ids: [String]) throws -> [ExerciseModel] {
        try exerciseTemplateManager.getLocalExerciseTemplates(ids: ids)
    }
    
    func getAllLocalExerciseTemplates() throws -> [ExerciseModel] {
        try exerciseTemplateManager.getAllLocalExerciseTemplates()
    }
    
    func getSystemExerciseTemplates() throws -> [ExerciseModel] {
        try exerciseTemplateManager.getSystemExerciseTemplates()
    }
    
    func createExerciseTemplate(exercise: ExerciseModel, image: PlatformImage?) async throws {
        try await exerciseTemplateManager.createExerciseTemplate(exercise: exercise, image: image)
    }
    
    func getExerciseTemplate(id: String) async throws -> ExerciseModel {
        try await exerciseTemplateManager.getExerciseTemplate(id: id)
    }
    
    func getExerciseTemplates(ids: [String], limitTo: Int = 20) async throws -> [ExerciseModel] {
        try await exerciseTemplateManager.getExerciseTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseModel] {
        try await exerciseTemplateManager.getExerciseTemplatesByName(name: name)
    }
    
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseModel] {
        try await exerciseTemplateManager.getExerciseTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopExerciseTemplatesByClicks(limitTo: Int = 10) async throws -> [ExerciseModel] {
        try await exerciseTemplateManager.getTopExerciseTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementExerciseTemplateInteraction(id: String) async throws {
        try await exerciseTemplateManager.incrementExerciseTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromExerciseTemplate(id: String) async throws {
        try await exerciseTemplateManager.removeAuthorIdFromExerciseTemplate(id: id)
    }
    
    func removeAuthorIdFromAllExerciseTemplates(id: String) async throws {
        try await exerciseTemplateManager.removeAuthorIdFromAllExerciseTemplates(id: id)
    }
    
    func bookmarkExerciseTemplate(id: String, isBookmarked: Bool) async throws {
        try await exerciseTemplateManager.bookmarkExerciseTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteExerciseTemplate(id: String, isFavourited: Bool) async throws {
        try await exerciseTemplateManager.favouriteExerciseTemplate(id: id, isFavourited: isFavourited)
    }
    
    // MARK: ExerciseUnitPreferenceManager
    
    func getPreference(templateId: String) -> ExerciseUnitPreference {
        exerciseUnitPreferenceManager.getPreference(for: templateId)
    }
    
    /// Set the weight unit preference for a specific exercise template
    func setWeightUnit(_ unit: ExerciseWeightUnit, for templateId: String) {
        exerciseUnitPreferenceManager.setWeightUnit(unit, for: templateId)
    }
    
    /// Set the distance unit preference for a specific exercise template
    func setDistanceUnit(_ unit: ExerciseDistanceUnit, for templateId: String) {
        exerciseUnitPreferenceManager.setDistanceUnit(unit, for: templateId)
    }
    
    /// Set both unit preferences for a specific exercise template
    func setPreference(weightUnit: ExerciseWeightUnit? = nil, distanceUnit: ExerciseDistanceUnit? = nil, for templateId: String) {
        exerciseUnitPreferenceManager.setPreference(weightUnit: weightUnit, distanceUnit: distanceUnit, for: templateId)
    }
    
    /// Clear all cached preferences (useful when user signs out)
    func clearCache() {
        exerciseUnitPreferenceManager.clearCache()
    }
    
    // MARK: WorkoutTemplateManager
    
    func addLocalWorkoutTemplate(workout: WorkoutTemplateModel) async throws {
        try await workoutTemplateManager.incrementWorkoutTemplateInteraction(id: workout.id)
    }
    
    func getLocalWorkoutTemplate(id: String) throws -> WorkoutTemplateModel {
        try workoutTemplateManager.getLocalWorkoutTemplate(id: id)
    }
    
    func getLocalWorkoutTemplates(ids: [String]) throws -> [WorkoutTemplateModel] {
        try workoutTemplateManager.getLocalWorkoutTemplates(ids: ids)
    }
    
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel] {
        try workoutTemplateManager.getAllLocalWorkoutTemplates()
    }
    
    func createWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws {
        try await workoutTemplateManager.createWorkoutTemplate(workout: workout, image: image)
    }
    
    func updateWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws {
        try await workoutTemplateManager.updateWorkoutTemplate(workout: workout, image: image)
    }
    
    func deleteWorkoutTemplate(id: String) async throws {
        try await workoutTemplateManager.deleteWorkoutTemplate(id: id)
    }
    
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel {
        try await workoutTemplateManager.getWorkoutTemplate(id: id)
    }
    
    func get(id: String) async -> WorkoutTemplateModel? {
        return try? await workoutTemplateManager.getWorkoutTemplate(id: id)
    }
    
    func getWorkoutTemplates(ids: [String], limitTo: Int = 20) async throws -> [WorkoutTemplateModel] {
        try await workoutTemplateManager.getWorkoutTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getWorkoutTemplatesByName(name: String) async throws -> [WorkoutTemplateModel] {
        try await workoutTemplateManager.getWorkoutTemplatesByName(name: name)
    }
    
    func getWorkoutTemplatesForAuthor(authorId: String) async throws -> [WorkoutTemplateModel] {
        try await workoutTemplateManager.getWorkoutTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopWorkoutTemplatesByClicks(limitTo: Int = 10) async throws -> [WorkoutTemplateModel] {
        try await workoutTemplateManager.getTopWorkoutTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementWorkoutTemplateInteraction(id: String) async throws {
        try await workoutTemplateManager.incrementWorkoutTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromWorkoutTemplate(id: String) async throws {
        try await workoutTemplateManager.removeAuthorIdFromWorkoutTemplate(id: id)
    }
    
    func removeAuthorIdFromAllWorkoutTemplates(id: String) async throws {
        try await workoutTemplateManager.removeAuthorIdFromAllWorkoutTemplates(id: id)
    }
    
    func bookmarkWorkoutTemplate(id: String, isBookmarked: Bool) async throws {
        try await workoutTemplateManager.bookmarkWorkoutTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteWorkoutTemplate(id: String, isFavourited: Bool) async throws {
        try await workoutTemplateManager.favouriteWorkoutTemplate(id: id, isFavourited: isFavourited)
    }
    
    // MARK: WorkoutSessionManager
    
    var activeSession: WorkoutSessionModel? {
        workoutSessionManager.activeSession
    }

    var restEndTime: Date? {
        workoutSessionManager.restEndTime
    }
    
    var sessionLastModified: Date? {
        workoutSessionManager.sessionsLastModified
    }
    
    func setActiveSession(_ session: WorkoutSessionModel?) {
        workoutSessionManager.activeSession = session
    }

    func startActiveSession(_ session: WorkoutSessionModel) {
        workoutSessionManager.startActiveSession(session)
    }
    
    func endActiveSession(markScheduledComplete: Bool = true) async {
        await workoutSessionManager.endActiveSession(markScheduledComplete: markScheduledComplete)
    }
    
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel? {
        try workoutSessionManager.getActiveLocalWorkoutSession()
    }
    
    func setActiveLocalWorkoutSession(_ session: WorkoutSessionModel?) throws {
        try workoutSessionManager.setActiveLocalWorkoutSession(session)
    }
    
    // Local Operations
    
    // Create
    func addLocalWorkoutSession(session: WorkoutSessionModel) throws {
        try workoutSessionManager.addLocalWorkoutSession(session: session)
    }
    
    // Read
    func getLocalWorkoutSession(id: String) throws -> WorkoutSessionModel {
        try workoutSessionManager.getLocalWorkoutSession(id: id)
    }
    
    func getLocalWorkoutSessions(ids: [String]) throws -> [WorkoutSessionModel] {
        try workoutSessionManager.getLocalWorkoutSessions(ids: ids)
    }
    
    func getAllLocalWorkoutSessions() throws -> [WorkoutSessionModel] {
        try workoutSessionManager.getAllLocalWorkoutSessions()
    }
    
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel] {
        try workoutSessionManager.getLocalWorkoutSessionsForAuthor(authorId: authorId, limitTo: limitTo)
    }
    
    // Update
    func updateLocalWorkoutSession(session: WorkoutSessionModel) throws {
        try workoutSessionManager.updateLocalWorkoutSession(session: session)
    }
    
    func endLocalWorkoutSession(id: String, at endedAt: Date) throws {
        try workoutSessionManager.endLocalWorkoutSession(id: id, at: endedAt)
    }
    
    // Delete
    func deleteLocalWorkoutSession(id: String) throws {
        try workoutSessionManager.deleteLocalWorkoutSession(id: id)
    }
    
    func deleteAllLocalWorkoutSessionsForAuthor(authorId: String) throws {
        try workoutSessionManager.deleteAllLocalWorkoutSessionsForAuthor(authorId: authorId)
    }

    func clearAllLocalStepsData() throws {
        try stepsManager.clearAllLocalStepsData()
    }
    
    // Remote Operations
    
    // Create
    func createWorkoutSession(session: WorkoutSessionModel) async throws {
        try await workoutSessionManager.createWorkoutSession(session: session)
    }
    
    // Read
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel {
        try await workoutSessionManager.getWorkoutSession(id: id)
    }
    
    /// Get workout session, trying local storage first, then falling back to remote
    func getWorkoutSessionWithFallback(id: String) async throws -> WorkoutSessionModel {
        try await workoutSessionManager.getWorkoutSessionWithFallback(id: id)
    }
    
    func getWorkoutSessions(ids: [String], limitTo: Int = 20) async throws -> [WorkoutSessionModel] {
        try await workoutSessionManager.getWorkoutSessions(ids: ids, limitTo: limitTo)
    }
    
    func getWorkoutSessionsByTemplateAndAuthor(templateId: String, authorId: String, limitTo: Int) async throws -> [WorkoutSessionModel] {
        try await workoutSessionManager.getWorkoutSessionsByTemplateAndAuthor(templateId: templateId, authorId: authorId, limitTo: limitTo)
    }
    
    func getWorkoutSessionsForAuthor(authorId: String, limitTo: Int = 20) async throws -> [WorkoutSessionModel] {
        try await workoutSessionManager.getWorkoutSessionsForAuthor(authorId: authorId, limitTo: limitTo)
    }
    
    func getLastCompletedSessionForTemplate(templateId: String, authorId: String) async throws -> WorkoutSessionModel? {
        try await workoutSessionManager.getLastCompletedSessionForTemplate(templateId: templateId, authorId: authorId)
    }
    
    // Update
    func updateWorkoutSession(session: WorkoutSessionModel) async throws {
        try await workoutSessionManager.updateWorkoutSession(session: session)
    }
    
    func endWorkoutSession(id: String, at endedAt: Date) async throws {
        try await workoutSessionManager.endWorkoutSession(id: id, at: endedAt)
    }
    
    // Delete
    func deleteWorkoutSession(id: String) async throws {
        try await workoutSessionManager.deleteWorkoutSession(id: id)
    }
    
    func deleteAllWorkoutSessionsForAuthor(authorId: String) async throws {
        try await workoutSessionManager.deleteAllWorkoutSessionsForAuthor(authorId: authorId)
    }
    
    // Sync Operations
    
    /// Syncs workout sessions from remote Firebase to local storage
    /// Fetches recent sessions and upserts them into local store
    func syncWorkoutSessionsFromRemote(authorId: String, limitTo: Int = 100) async throws {
        try await workoutSessionManager.syncWorkoutSessionsFromRemote(authorId: authorId, limitTo: limitTo)
    }
    
    // MARK: ExerciseHistoryManager
    
    func addLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws {
        try exerciseHistoryManager.addLocalExerciseHistory(entry: entry)
    }
    
    func updateLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws {
        try exerciseHistoryManager.updateLocalExerciseHistory(entry: entry)
    }
    
    func getLocalExerciseHistory(id: String) throws -> ExerciseHistoryEntryModel {
        try exerciseHistoryManager.getLocalExerciseHistory(id: id)
    }
    
    func getLocalExerciseHistoryForTemplate(templateId: String, limitTo: Int = 50) throws -> [ExerciseHistoryEntryModel] {
        try exerciseHistoryManager.getLocalExerciseHistoryForTemplate(templateId: templateId, limitTo: limitTo)
    }
    
    func getLocalExerciseHistoryForAuthor(authorId: String, limitTo: Int = 50) throws -> [ExerciseHistoryEntryModel] {
        try exerciseHistoryManager.getLocalExerciseHistoryForAuthor(authorId: authorId, limitTo: limitTo)
    }
    
    func getAllLocalExerciseHistory() throws -> [ExerciseHistoryEntryModel] {
        try exerciseHistoryManager.getAllLocalExerciseHistory()
    }
    
    func deleteLocalExerciseHistory(id: String) throws {
        try exerciseHistoryManager.deleteLocalExerciseHistory(id: id)
    }
    
    func deleteAllLocalExerciseHistoryForAuthor(authorId: String) throws {
        try exerciseHistoryManager.deleteAllLocalExerciseHistoryForAuthor(authorId: authorId)
    }
    
    // Remote
    func createExerciseHistory(entry: ExerciseHistoryEntryModel) async throws {
        try await exerciseHistoryManager.createExerciseHistory(entry: entry)
    }
    
    func updateExerciseHistory(entry: ExerciseHistoryEntryModel) async throws {
        try await exerciseHistoryManager.updateExerciseHistory(entry: entry)
    }
    
    func getExerciseHistory(id: String) async throws -> ExerciseHistoryEntryModel {
        try await exerciseHistoryManager.getExerciseHistory(id: id)
    }
    
    func getExerciseHistoryForTemplate(templateId: String, limitTo: Int = 50) async throws -> [ExerciseHistoryEntryModel] {
        try await exerciseHistoryManager.getExerciseHistoryForTemplate(templateId: templateId, limitTo: limitTo)
    }
    
    func getExerciseHistoryForAuthor(authorId: String, limitTo: Int = 50) async throws -> [ExerciseHistoryEntryModel] {
        try await exerciseHistoryManager.getExerciseHistoryForAuthor(authorId: authorId, limitTo: limitTo)
    }
    
    func deleteExerciseHistory(id: String) async throws {
        try await exerciseHistoryManager.deleteExerciseHistory(id: id)
    }
    
    func deleteAllExerciseHistoryForAuthor(authorId: String) async throws {
        try await exerciseHistoryManager.deleteAllExerciseHistoryForAuthor(authorId: authorId)
    }
    
    // MARK: TrainingProgramManager
    
    var activeTrainingProgram: TrainingProgram? {
        trainingProgramManager.activeTrainingProgram
    }
    
    func setActiveTrainingProgram(programId: String) async throws {
        try await userManager.updateActiveTrainingProgramId(programId: programId)
    }
       
    @discardableResult
    func getActiveTrainingProgram() throws -> TrainingProgram? {
        guard let programId = currentUser?.activeTrainingProgramId else { return nil }
        return try trainingProgramManager.readActiveTrainingProgram(programId: programId)
    }
    
    // CREATE
    
    func createTrainingProgram(program: TrainingProgram) async throws {
        try await trainingProgramManager.createTrainingProgram(program: program)
    }

    // UPSERT

    func upsertTrainingProgram(program: TrainingProgram) async throws {
        do {
            try await trainingProgramManager.updateTrainingProgram(program: program)
        } catch {
            let urlError = error as? URLError
            if urlError?.code == .fileDoesNotExist {
                try await trainingProgramManager.createTrainingProgram(program: program)
            } else {
                throw error
            }
        }
    }
    
    // READ
    
    func readLocalTrainingProgram(programId: String) throws -> TrainingProgram {
        try trainingProgramManager.readLocalTrainingProgram(programId: programId)
    }
    
    func readAllLocalTrainingPrograms() throws -> [TrainingProgram] {
        try trainingProgramManager.readAllLocalTrainingPrograms()
    }
    
    func readRemoteTrainingProgram(programId: String) async throws -> TrainingProgram {
        try await trainingProgramManager.readRemoteTrainingProgram(programId: programId)
    }
    
    func readAllRemoteTrainingProgramsForAuthor(userId: String) async throws -> [TrainingProgram] {
        try await trainingProgramManager.readAllRemoteTrainingProgramsForAuthor(userId: userId)
    }
    
    // UPDATE
    
    func updateTrainingProgram(program: TrainingProgram) async throws {
        try await trainingProgramManager.updateTrainingProgram(program: program)
    }
    
    // DELETE
    
    func deleteTrainingProgram(program: TrainingProgram) async throws {
        try await trainingProgramManager.deleteTrainingProgram(program: program)
    }
    
    // MARK: GymProfileManager
    
    var favouriteGymProfile: GymProfileModel? {
        guard let favouriteGymProfileId = currentUser?.favouriteGymProfileId else { return nil }
        return try? readLocalGymProfile(profileId: favouriteGymProfileId)
    }
    
    // CREATE
    func createGymProfile(profile: GymProfileModel) async throws {
        try await gymProfileManager.createGymProfile(profile: profile)
    }

    // READ
    
    func readFavouriteGymProfile() async throws -> GymProfileModel {
        guard let user = currentUser,
              let favourite = user.favouriteGymProfileId else { throw CoreError.noCurrentUser }
        do {
            return try gymProfileManager.readLocalGymProfile(profileId: favourite)
        } catch {
            return try await gymProfileManager.readRemoteGymProfile(profileId: favourite)
        }
    }
    
    func readLocalGymProfile(profileId: String) throws -> GymProfileModel {
        try gymProfileManager.readLocalGymProfile(profileId: profileId)
    }
    
    func readAllLocalGymProfiles() throws -> [GymProfileModel] {
        try gymProfileManager.readAllLocalGymProfiles()
    }
    
    func readRemoteGymProfile(profileId: String) async throws -> GymProfileModel {
        try await gymProfileManager.readRemoteGymProfile(profileId: profileId)
    }
    
    func readAllRemoteGymProfilesForAuthor(userId: String) async throws -> [GymProfileModel] {
        try await gymProfileManager.readAllRemoteGymProfilesForAuthor(userId: userId)
    }

    // UPDATE
    
    @discardableResult
    func updateGymProfile(profile: GymProfileModel, image: PlatformImage? = nil) async throws -> GymProfileModel {
        try await gymProfileManager.updateGymProfile(profile: profile, image: image)
    }

    // DELETE
        
    func deleteGymProfile(profile: GymProfileModel) async throws {
        try await gymProfileManager.deleteGymProfile(profile: profile)
    }
    
    // MARK: IngredientTemplateManager
    
    func addLocalIngredientTemplate(ingredient: IngredientTemplateModel) async throws {
        try await ingredientTemplateManager.addLocalIngredientTemplate(ingredient: ingredient)
    }
    
    func getLocalIngredientTemplate(id: String) throws -> IngredientTemplateModel {
        try ingredientTemplateManager.getLocalIngredientTemplate(id: id)
    }
    
    func getLocalIngredientTemplates(ids: [String]) throws -> [IngredientTemplateModel] {
        try ingredientTemplateManager.getLocalIngredientTemplates(ids: ids)
    }
    
    func getAllLocalIngredientTemplates() throws -> [IngredientTemplateModel] {
        try ingredientTemplateManager.getAllLocalIngredientTemplates()
    }
    
    func createIngredientTemplate(ingredient: IngredientTemplateModel, image: PlatformImage?) async throws {
        try await ingredientTemplateManager.createIngredientTemplate(ingredient: ingredient, image: image)
    }
    
    func getIngredientTemplate(id: String) async throws -> IngredientTemplateModel {
        try await ingredientTemplateManager.getIngredientTemplate(id: id)
    }
    
    func getIngredientTemplates(ids: [String], limitTo: Int = 20) async throws -> [IngredientTemplateModel] {
        try await ingredientTemplateManager.getIngredientTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel] {
        try await ingredientTemplateManager.getIngredientTemplatesByName(name: name)
    }
    
    func getIngredientTemplatesForAuthor(authorId: String) async throws -> [IngredientTemplateModel] {
        try await ingredientTemplateManager.getIngredientTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopIngredientTemplatesByClicks(limitTo: Int = 10) async throws -> [IngredientTemplateModel] {
        try await ingredientTemplateManager.getTopIngredientTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementIngredientTemplateInteraction(id: String) async throws {
        try await ingredientTemplateManager.incrementIngredientTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromIngredientTemplate(id: String) async throws {
        try await ingredientTemplateManager.removeAuthorIdFromIngredientTemplate(id: id)
    }
    
    func removeAuthorIdFromAllIngredientTemplates(id: String) async throws {
        try await ingredientTemplateManager.removeAuthorIdFromAllIngredientTemplates(id: id)
    }
    
    func bookmarkIngredientTemplate(id: String, isBookmarked: Bool) async throws {
        try await ingredientTemplateManager.bookmarkIngredientTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteIngredientTemplate(id: String, isFavourited: Bool) async throws {
        try await ingredientTemplateManager.favouriteIngredientTemplate(id: id, isFavourited: isFavourited)
    }
    
    // MARK: RecipeTemplateManager
    
    func addLocalRecipeTemplate(recipe: RecipeTemplateModel) async throws {
        try await recipeTemplateManager.addLocalRecipeTemplate(recipe: recipe)
    }
    
    func getLocalRecipeTemplate(id: String) throws -> RecipeTemplateModel {
        try recipeTemplateManager.getLocalRecipeTemplate(id: id)
    }
    
    func getLocalRecipeTemplates(ids: [String]) throws -> [RecipeTemplateModel] {
        try recipeTemplateManager.getLocalRecipeTemplates(ids: ids)
    }
    
    func getAllLocalRecipeTemplates() throws -> [RecipeTemplateModel] {
        try recipeTemplateManager.getAllLocalRecipeTemplates()
    }
    
    func createRecipeTemplate(recipe: RecipeTemplateModel, image: PlatformImage?) async throws {
        try await recipeTemplateManager.createRecipeTemplate(recipe: recipe, image: image)
    }
    
    func getRecipeTemplate(id: String) async throws -> RecipeTemplateModel {
        try await recipeTemplateManager.getRecipeTemplate(id: id)
    }
    
    func getRecipeTemplates(ids: [String], limitTo: Int = 20) async throws -> [RecipeTemplateModel] {
        try await recipeTemplateManager.getRecipeTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getRecipeTemplatesByName(name: String) async throws -> [RecipeTemplateModel] {
        try await recipeTemplateManager.getRecipeTemplatesByName(name: name)
    }
    
    func getRecipeTemplatesForAuthor(authorId: String) async throws -> [RecipeTemplateModel] {
        try await recipeTemplateManager.getRecipeTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopRecipeTemplatesByClicks(limitTo: Int = 10) async throws -> [RecipeTemplateModel] {
        try await recipeTemplateManager.getTopRecipeTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementRecipeTemplateInteraction(id: String) async throws {
        try await recipeTemplateManager.incrementRecipeTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromRecipeTemplate(id: String) async throws {
        try await recipeTemplateManager.removeAuthorIdFromRecipeTemplate(id: id)
    }
    
    func removeAuthorIdFromAllRecipeTemplates(id: String) async throws {
        try await recipeTemplateManager.removeAuthorIdFromAllRecipeTemplates(id: id)
    }
    
    func bookmarkRecipeTemplate(id: String, isBookmarked: Bool) async throws {
        try await recipeTemplateManager.bookmarkRecipeTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteRecipeTemplate(id: String, isFavourited: Bool) async throws {
        try await recipeTemplateManager.favouriteRecipeTemplate(id: id, isFavourited: isFavourited)
    }
    
    // MARK: NutritionManager
    
    var currentDietPlan: DietPlan? {
        nutritionManager.currentDietPlan
    }

    func computeDietPlan(user: UserModel?, builder: DietPlanBuilder) -> DietPlan {
        nutritionManager.computeDietPlan(user: user, builder: builder)
    }

    func saveDietPlan(plan: DietPlan) async throws {
        try await nutritionManager.saveDietPlan(plan: plan)
    }

    func createAndSaveDietPlan(user: UserModel?, builder: DietPlanBuilder) async throws {
        try await nutritionManager.createAndSaveDietPlan(user: user, builder: builder)
    }
    
    // Get daily macro target for a specific date from the current diet plan
    func getDailyTarget(for date: Date, userId: String) async throws -> DailyMacroTarget? {
        try await nutritionManager.getDailyTarget(for: date, userId: userId)
    }
    
    // Estimation
    func estimateTDEE(user: UserModel?) -> Double {
        nutritionManager.estimateTDEE(user: user)
    }
    
    // MARK: MealLogManager
    
    var draftMeal: MealLogModel? {
        mealLogManager.draftMeal
    }
    
    func addMeal(_ meal: MealLogModel) async throws {
        try await mealLogManager.addMeal(meal)
    }
    
    func updateMealAndSync(_ meal: MealLogModel) async throws {
        try await mealLogManager.updateMealAndSync(meal)
    }
    
    func deleteMealAndSync(id: String, dayKey: String, authorId: String) async throws {
        try await mealLogManager.deleteMealAndSync(id: id, dayKey: dayKey, authorId: authorId)
    }
    
    func getMeals(for dayKey: String) throws -> [MealLogModel] {
        try mealLogManager.getMeals(for: dayKey)
    }
    
    func getMeals(startDayKey: String, endDayKey: String) throws -> [MealLogModel] {
        try mealLogManager.getLocalMeals(startDayKey: startDayKey, endDayKey: endDayKey)
    }
    
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget {
        try mealLogManager.getLocalDailyTotals(dayKey: dayKey)
    }
    
    func getDailyTotals(startDayKey: String, endDayKey: String) throws -> [(dayKey: String, totals: DailyMacroTarget)] {
        guard let startDate = Date(dayKey: startDayKey), let endDate = Date(dayKey: endDayKey), startDate <= endDate else {
            return []
        }
        let keys = Date.dayKeys(from: startDate, to: endDate)
        return keys.map { key in
            (dayKey: key, totals: (try? mealLogManager.getLocalDailyTotals(dayKey: key)) ?? DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0))
        }
    }
    
    // LocalMealLogPersistence
    
    func addLocalMeal(_ meal: MealLogModel) throws {
        try mealLogManager.addLocalMeal(meal)
    }
    
    func updateLocalMeal(_ meal: MealLogModel) throws {
        try mealLogManager.updateLocalMeal(meal)
    }
    
    func deleteLocalMeal(id: String, dayKey: String) throws {
        try mealLogManager.deleteLocalMeal(id: id, dayKey: dayKey)
    }
    
    func getLocalMeal(id: String) throws -> MealLogModel {
        try mealLogManager.getLocalMeal(id: id)
    }
    
    func getLocalMeals(dayKey: String) throws -> [MealLogModel] {
        try mealLogManager.getLocalMeals(dayKey: dayKey)
    }
    
    func getLocalMeals(startDayKey: String, endDayKey: String) throws -> [MealLogModel] {
        try mealLogManager.getLocalMeals(startDayKey: startDayKey, endDayKey: endDayKey)
    }
    
    func getLocalDailyTotals(dayKey: String) throws -> DailyMacroTarget {
        try mealLogManager.getLocalDailyTotals(dayKey: dayKey)
    }
    
    func getDailyNutritionBreakdown(dayKey: String) throws -> DailyNutritionBreakdown {
        let meals = try mealLogManager.getMeals(for: dayKey)
        var breakdown = DailyNutritionBreakdown()
        for meal in meals {
            for item in meal.items {
                if item.sourceType == .ingredient {
                    if let ingredient = try? ingredientTemplateManager.getLocalIngredientTemplate(id: item.sourceId) {
                        let scale = ((item.resolvedGrams ?? item.resolvedMilliliters) ?? 0) / 100.0
                        addIngredientToBreakdown(ingredient, scale: scale, into: &breakdown)
                    }
                } else if item.sourceType == .recipe {
                    if let recipe = try? recipeTemplateManager.getLocalRecipeTemplate(id: item.sourceId) {
                        let recipeTotals = aggregateRecipeNutrients(recipe: recipe)
                        let scale = item.amount
                        addRecipeTotalsToBreakdown(recipeTotals, scale: scale, into: &breakdown)
                    }
                }
            }
        }
        if let fiber = breakdown.fiberGrams, let carbs = try? mealLogManager.getLocalDailyTotals(dayKey: dayKey).carbGrams {
            breakdown.netCarbsGrams = max(0, carbs - fiber)
        }
        return breakdown
    }
    
    func getDailyNutritionBreakdown(startDayKey: String, endDayKey: String) throws -> [(dayKey: String, breakdown: DailyNutritionBreakdown)] {
        guard let startDate = Date(dayKey: startDayKey), let endDate = Date(dayKey: endDayKey), startDate <= endDate else {
            return []
        }
        let keys = Date.dayKeys(from: startDate, to: endDate)
        return keys.map { key in
            (dayKey: key, breakdown: (try? getDailyNutritionBreakdown(dayKey: key)) ?? DailyNutritionBreakdown.empty)
        }
    }
    
    private func addIngredientToBreakdown(_ ingredient: IngredientTemplateModel, scale: Double, into breakdown: inout DailyNutritionBreakdown) {
        func add(_ value: Double?, to keyPath: inout Double?) {
            guard let value, value > 0 else { return }
            keyPath = (keyPath ?? 0) + value * scale
        }
        add(ingredient.fiber, to: &breakdown.fiberGrams)
        add(ingredient.sugar, to: &breakdown.sugarGrams)
        add(ingredient.fatSaturated, to: &breakdown.fatSaturatedGrams)
        add(ingredient.fatMonounsaturated, to: &breakdown.fatMonounsaturatedGrams)
        add(ingredient.fatPolyunsaturated, to: &breakdown.fatPolyunsaturatedGrams)
        add(ingredient.sodiumMg, to: &breakdown.sodiumMg)
        add(ingredient.potassiumMg, to: &breakdown.potassiumMg)
        add(ingredient.calciumMg, to: &breakdown.calciumMg)
        add(ingredient.ironMg, to: &breakdown.ironMg)
        add(ingredient.magnesiumMg, to: &breakdown.magnesiumMg)
        add(ingredient.zincMg, to: &breakdown.zincMg)
        add(ingredient.copperMg, to: &breakdown.copperMg)
        add(ingredient.manganeseMg, to: &breakdown.manganeseMg)
        add(ingredient.phosphorusMg, to: &breakdown.phosphorusMg)
        add(ingredient.seleniumMcg, to: &breakdown.seleniumMcg)
        add(ingredient.vitaminAMcg, to: &breakdown.vitaminAMcg)
        add(ingredient.vitaminB6Mg, to: &breakdown.vitaminB6Mg)
        add(ingredient.vitaminB12Mcg, to: &breakdown.vitaminB12Mcg)
        add(ingredient.vitaminCMg, to: &breakdown.vitaminCMg)
        add(ingredient.vitaminDMcg, to: &breakdown.vitaminDMcg)
        add(ingredient.vitaminEMg, to: &breakdown.vitaminEMg)
        add(ingredient.vitaminKMcg, to: &breakdown.vitaminKMcg)
        add(ingredient.thiaminMg, to: &breakdown.thiaminMg)
        add(ingredient.riboflavinMg, to: &breakdown.riboflavinMg)
        add(ingredient.niacinMg, to: &breakdown.niacinMg)
        add(ingredient.pantothenicAcidMg, to: &breakdown.pantothenicAcidMg)
        add(ingredient.folateMcg, to: &breakdown.folateMcg)
        add(ingredient.caffeineMg, to: &breakdown.caffeineMg)
        add(ingredient.cholesterolMg, to: &breakdown.cholesterolMg)
    }
    
    private struct RecipeNutrientTotals {
        var fiberGrams: Double = 0
        var sugarGrams: Double = 0
        var fatSaturatedGrams: Double = 0
        var fatMonounsaturatedGrams: Double = 0
        var fatPolyunsaturatedGrams: Double = 0
        var sodiumMg: Double = 0
        var potassiumMg: Double = 0
        var calciumMg: Double = 0
        var ironMg: Double = 0
        var magnesiumMg: Double = 0
        var zincMg: Double = 0
        var copperMg: Double = 0
        var manganeseMg: Double = 0
        var phosphorusMg: Double = 0
        var seleniumMcg: Double = 0
        var vitaminAMcg: Double = 0
        var vitaminB6Mg: Double = 0
        var vitaminB12Mcg: Double = 0
        var vitaminCMg: Double = 0
        var vitaminDMcg: Double = 0
        var vitaminEMg: Double = 0
        var vitaminKMcg: Double = 0
        var thiaminMg: Double = 0
        var riboflavinMg: Double = 0
        var niacinMg: Double = 0
        var pantothenicAcidMg: Double = 0
        var folateMcg: Double = 0
        var caffeineMg: Double = 0
        var cholesterolMg: Double = 0
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    private func aggregateRecipeNutrients(recipe: RecipeTemplateModel) -> RecipeNutrientTotals {
        var totals = RecipeNutrientTotals()
        for ringredient in recipe.ingredients {
            let grams: Double
            switch ringredient.unit {
            case .grams: grams = ringredient.amount
            case .milliliters: grams = ringredient.amount
            case .units: grams = ringredient.amount * 100
            }
            let scale = grams / 100.0
            let ingredient = ringredient.ingredient
            if let value = ingredient.fiber { totals.fiberGrams += value * scale }
            if let value = ingredient.sugar { totals.sugarGrams += value * scale }
            if let value = ingredient.fatSaturated { totals.fatSaturatedGrams += value * scale }
            if let value = ingredient.fatMonounsaturated { totals.fatMonounsaturatedGrams += value * scale }
            if let value = ingredient.fatPolyunsaturated { totals.fatPolyunsaturatedGrams += value * scale }
            if let value = ingredient.sodiumMg { totals.sodiumMg += value * scale }
            if let value = ingredient.potassiumMg { totals.potassiumMg += value * scale }
            if let value = ingredient.calciumMg { totals.calciumMg += value * scale }
            if let value = ingredient.ironMg { totals.ironMg += value * scale }
            if let value = ingredient.magnesiumMg { totals.magnesiumMg += value * scale }
            if let value = ingredient.zincMg { totals.zincMg += value * scale }
            if let value = ingredient.copperMg { totals.copperMg += value * scale }
            if let value = ingredient.manganeseMg { totals.manganeseMg += value * scale }
            if let value = ingredient.phosphorusMg { totals.phosphorusMg += value * scale }
            if let value = ingredient.seleniumMcg { totals.seleniumMcg += value * scale }
            if let value = ingredient.vitaminAMcg { totals.vitaminAMcg += value * scale }
            if let value = ingredient.vitaminB6Mg { totals.vitaminB6Mg += value * scale }
            if let value = ingredient.vitaminB12Mcg { totals.vitaminB12Mcg += value * scale }
            if let value = ingredient.vitaminCMg { totals.vitaminCMg += value * scale }
            if let value = ingredient.vitaminDMcg { totals.vitaminDMcg += value * scale }
            if let value = ingredient.vitaminEMg { totals.vitaminEMg += value * scale }
            if let value = ingredient.vitaminKMcg { totals.vitaminKMcg += value * scale }
            if let value = ingredient.thiaminMg { totals.thiaminMg += value * scale }
            if let value = ingredient.riboflavinMg { totals.riboflavinMg += value * scale }
            if let value = ingredient.niacinMg { totals.niacinMg += value * scale }
            if let value = ingredient.pantothenicAcidMg { totals.pantothenicAcidMg += value * scale }
            if let value = ingredient.folateMcg { totals.folateMcg += value * scale }
            if let value = ingredient.caffeineMg { totals.caffeineMg += value * scale }
            if let value = ingredient.cholesterolMg { totals.cholesterolMg += value * scale }
        }
        return totals
    }
    
    private func addRecipeTotalsToBreakdown(_ totals: RecipeNutrientTotals, scale: Double, into breakdown: inout DailyNutritionBreakdown) {
        func add(_ value: Double, to keyPath: inout Double?) {
            guard value > 0 else { return }
            keyPath = (keyPath ?? 0) + value * scale
        }
        add(totals.fiberGrams, to: &breakdown.fiberGrams)
        add(totals.sugarGrams, to: &breakdown.sugarGrams)
        add(totals.fatSaturatedGrams, to: &breakdown.fatSaturatedGrams)
        add(totals.fatMonounsaturatedGrams, to: &breakdown.fatMonounsaturatedGrams)
        add(totals.fatPolyunsaturatedGrams, to: &breakdown.fatPolyunsaturatedGrams)
        add(totals.sodiumMg, to: &breakdown.sodiumMg)
        add(totals.potassiumMg, to: &breakdown.potassiumMg)
        add(totals.calciumMg, to: &breakdown.calciumMg)
        add(totals.ironMg, to: &breakdown.ironMg)
        add(totals.magnesiumMg, to: &breakdown.magnesiumMg)
        add(totals.zincMg, to: &breakdown.zincMg)
        add(totals.copperMg, to: &breakdown.copperMg)
        add(totals.manganeseMg, to: &breakdown.manganeseMg)
        add(totals.phosphorusMg, to: &breakdown.phosphorusMg)
        add(totals.seleniumMcg, to: &breakdown.seleniumMcg)
        add(totals.vitaminAMcg, to: &breakdown.vitaminAMcg)
        add(totals.vitaminB6Mg, to: &breakdown.vitaminB6Mg)
        add(totals.vitaminB12Mcg, to: &breakdown.vitaminB12Mcg)
        add(totals.vitaminCMg, to: &breakdown.vitaminCMg)
        add(totals.vitaminDMcg, to: &breakdown.vitaminDMcg)
        add(totals.vitaminEMg, to: &breakdown.vitaminEMg)
        add(totals.vitaminKMcg, to: &breakdown.vitaminKMcg)
        add(totals.thiaminMg, to: &breakdown.thiaminMg)
        add(totals.riboflavinMg, to: &breakdown.riboflavinMg)
        add(totals.niacinMg, to: &breakdown.niacinMg)
        add(totals.pantothenicAcidMg, to: &breakdown.pantothenicAcidMg)
        add(totals.folateMcg, to: &breakdown.folateMcg)
        add(totals.caffeineMg, to: &breakdown.caffeineMg)
        add(totals.cholesterolMg, to: &breakdown.cholesterolMg)
    }
    
    // RemoteMealLogService
    
    func createMeal(_ meal: MealLogModel) async throws {
        try await mealLogManager.createMeal(meal)
    }
    
    func updateMeal(_ meal: MealLogModel) async throws {
        try await mealLogManager.updateMeal(meal)
    }
    
    func deleteMeal(id: String, dayKey: String, authorId: String) async throws {
        try await mealLogManager.deleteMeal(id: id, dayKey: dayKey, authorId: authorId)
    }
    
    func getMeals(dayKey: String, authorId: String, limitTo: Int) async throws -> [MealLogModel] {
        try await mealLogManager.getMeals(dayKey: dayKey, authorId: authorId, limitTo: limitTo)
    }
    
    func getMeals(startDayKey: String, endDayKey: String, authorId: String, limitTo: Int) async throws -> [MealLogModel] {
        try await mealLogManager.getMeals(startDayKey: startDayKey, endDayKey: endDayKey, authorId: authorId, limitTo: limitTo)
    }
    
    // MARK: PushManager
    
    func requestPushAuthorisation() async throws -> Bool {
        try await pushManager.requestAuthorisation()
    }
    
    func canRequestNotificationAuthorisation() async -> Bool {
        await pushManager.canRequestAuthorisation()
    }
    
    func schedulePushNotificationsForNextWeek() {
        pushManager.schedulePushNotificationsForNextWeek()
    }
    
    func schedulePushNotification(title: String, body: String, date: Date) async throws {
        try await pushManager.schedulePushNotification(title: title, body: body, date: date)
    }
    
    func schedulePushNotification(identifier: String, title: String, body: String, date: Date) async throws {
        try await pushManager.schedulePushNotification(identifier: identifier, title: title, body: body, date: date)
    }
    
    func getDeliveredNotifications() async -> [UNNotification] {
        await pushManager.getDeliveredNotifications()
    }
    
    func removeDeliveredNotification(identifier: String) async {
        await pushManager.removeDeliveredNotification(identifier: identifier)
    }
    
    func removePendingNotifications(withIdentifiers identifiers: [String]) async {
        await pushManager.removePendingNotifications(withIdentifiers: identifiers)
    }
    
    func getNotificationAuthorisationStatus() async -> UNAuthorizationStatus {
        await pushManager.getAuthorizationStatus()
    }
    
    // MARK: AIManager
    
    func generateImage(input: String) async throws -> UIImage {
        try await aiManager.generateImage(input: input)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await aiManager.generateText(chats: chats)
    }
    
    // MARK: LogManager
    
    func identifyUser(userId: String, name: String?, email: String?) {
        logManager.identifyUser(userId: userId, name: name, email: email)
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        logManager.addUserProperties(dict: dict, isHighPriority: isHighPriority)
    }
    
    func deleteUserProfile() {
        logManager.deleteUserProfile()
    }
    
    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        logManager.trackEvent(eventName: eventName, parameters: parameters, type: type)
    }
    
    func trackEvent(event: AnyLoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        logManager.trackScreenView(event: event)
    }
        
    // ReportManager
    
    func report(contentType: ReportContentType, contentId: String, authorUserId: String?, reason: ReportReason, notes: String?) async throws {
        try await reportManager.report(contentType: contentType, contentId: contentId, authorUserId: authorUserId, reason: reason, notes: notes)
    }
    
    // HealthKitManager
    var healthKitIsAuthorized: Bool {
        healthKitManager.isAuthorized
    }
    
    func canRequestHealthDataAuthorisation() -> Bool {
        healthKitManager.canRequestAuthorisation()
    }
    
    func requestHealthKitAuthorisation() async throws {
        try await healthKitManager.requestAuthorisation()
    }
    
    func needsAuthorisationForRequiredTypes() -> Bool {
        healthKitManager.needsAuthorisationForRequiredTypes()
    }
    
    func getHealthStore() -> HKHealthStore {
        healthKitManager.getHealthStore()
    }

    // BodyMeasurementsManager

    var measurementHistory: [BodyMeasurementEntry] {
        bodyMeasurementsManager.measurementHistory
    }

    /// CREATE
    func createWeightEntry(weightEntry: BodyMeasurementEntry) async throws {
        try await bodyMeasurementsManager.createWeightEntry(weightEntry: weightEntry)
    }

    /// READ
    func readLocalWeightEntry(id: String) throws -> BodyMeasurementEntry {
        try bodyMeasurementsManager.readLocalWeightEntry(id: id)
    }

    func readRemoteWeightEntry(userId: String, entryId: String) async throws -> BodyMeasurementEntry {
        try await bodyMeasurementsManager.readRemoteWeightEntry(userId: userId, entryId: entryId)
    }

    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry] {
        try bodyMeasurementsManager.readAllLocalWeightEntries()
    }

    func readAllRemoteWeightEntries(userId: String) async throws -> [BodyMeasurementEntry] {
        try await bodyMeasurementsManager.readAllRemoteWeightEntries(userId: userId)
    }

    /// UPDATE
    func updateWeightEntry(entry: BodyMeasurementEntry) async throws {
        try await bodyMeasurementsManager.updateWeightEntry(entry: entry)
    }

    /// DELETE
    func deleteWeightEntry(userId: String, entryId: String) async throws {
        try await bodyMeasurementsManager.deleteWeightEntry(userId: userId, entryId: entryId)
    }

    func dedupeWeightEntriesByDay(userId: String) async throws {
        try await bodyMeasurementsManager.dedupeWeightEntriesByDay(userId: userId)
    }

    func backfillBodyFatFromHealthKit() async {
        guard let userId else { return }
        await bodyMeasurementsManager.backfillBodyFatFromHealthKit(userId: userId)
    }
    
    // MARK: ImageUploadManager
    
    func uploadImage(image: PlatformImage, path: String) async throws -> URL {
        try await imageUploadManager.uploadImage(image: image, path: path)
    }
    
    func deleteImage(path: String) async throws {
        try await imageUploadManager.deleteImage(path: path)
    }
    
    // MARK: GoalManager
    
    var currentGoal: WeightGoal? {
        goalManager.currentGoal
    }
    
    var goalHistory: [WeightGoal] {
        goalManager.goalHistory
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
    
    func getActiveGoal(userId: String) async throws -> WeightGoal? {
        try await goalManager.getActiveGoal(userId: userId)
    }
    
    func getAllGoals(userId: String) async throws -> [WeightGoal] {
        try await goalManager.getAllGoals(userId: userId)
    }
    
    func completeGoal(goalId: String, userId: String) async throws {
        try await goalManager.completeGoal(goalId: goalId, userId: userId)
    }
    
    func abandonGoal(goalId: String, userId: String) async throws {
        try await goalManager.abandonGoal(goalId: goalId, userId: userId)
    }
    
    func pauseGoal(goalId: String, userId: String) async throws {
        try await goalManager.pauseGoal(goalId: goalId, userId: userId)
    }
    
    /// Delete a goal
    func deleteGoal(goalId: String, userId: String) async throws {
        try await goalManager.deleteGoal(goalId: goalId, userId: userId)
    }
    
    // StepsManager

    var stepsHistory: [StepsModel] {
        stepsManager.stepsHistory
    }

    /// CREATE
    func createStepsEntry(steps: StepsModel) async throws {
        try await stepsManager.createStepsEntry(steps: steps)
    }

    /// READ
    func readLocalStepsEntry(id: String) throws -> StepsModel {
        try stepsManager.readLocalStepsEntry(id: id)
    }

    func readRemoteStepsEntry(userId: String, stepsId: String) async throws -> StepsModel {
        try await stepsManager.readRemoteStepsEntry(userId: userId, stepsId: stepsId)
    }

    func readAllLocalStepsEntries() throws -> [StepsModel] {
        try stepsManager.readAllLocalStepsEntries()
    }

    func readAllRemoteStepsEntries(userId: String) async throws -> [StepsModel] {
        try await stepsManager.readAllRemoteStepsEntries(userId: userId, userCreationDate: currentUser?.creationDate)
    }

    /// UPDATE
    func updateStepsEntry(steps: StepsModel) async throws {
        try await stepsManager.updateStepsEntry(steps: steps)
    }

    /// DELETE
    func deleteWeightEntry(userId: String, stepsId: String) async throws {
        try await stepsManager.deleteStepsEntry(userId: userId, stepsId: stepsId)
    }

    func dedupeStepsEntriesByDay(userId: String) async throws {
        try await stepsManager.dedupeStepsEntriesByDay(userId: userId)
    }

    func backfillStepsFromHealthKit() async {
        guard let userId else { return }
        await stepsManager.backfillStepsFromHealthKit(userId: userId, userCreationDate: currentUser?.creationDate)
    }
    
    // Testing Helper
    
    /// Set current goal directly (for previews and testing only)
    func setCurrentGoalForTesting(_ goal: WeightGoal?) {
        goalManager.setCurrentGoalForTesting(goal)
    }
    
    // MARK: HKWorkoutManager
    
    #if canImport(HealthKit) && !targetEnvironment(macCatalyst)
    var workoutSessionState: HKWorkoutSessionState? {
        hkWorkoutManager.state
    }
    
    var hkWorkoutRestEndTime: Date? {
        hkWorkoutManager.restEndTime
    }
    
    var hkWorkoutMetrics: MetricsModel {
        hkWorkoutManager.metrics
    }
    
    func setWorkoutConfiguration(activityType: HKWorkoutActivityType, location: HKWorkoutSessionLocationType) {
        hkWorkoutManager.setWorkoutConfiguration(activityType: activityType, location: location)
    }
    
    func prepareWorkout() async throws {
        try await hkWorkoutManager.prepareWorkout()
    }
    
    func startWorkout(workout: WorkoutSessionModel) {
        hkWorkoutManager.startWorkout(workout: workout)
    }
    
    // Recover the workout for the session.
    func recoverWorkout(workout: WorkoutSessionModel, recoveredSession: HKWorkoutSession) {
        hkWorkoutManager.recoverWorkout(workout: workout, recoveredSession: recoveredSession)
    }
    
    // State Control
    
    func pause() {
        hkWorkoutManager.pause()
    }
    
    func resume() {
        hkWorkoutManager.resume()
    }
    
    func togglePause() {
        hkWorkoutManager.togglePause()
    }
    
    func endWorkout() {
        hkWorkoutManager.endWorkout()
    }
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        hkWorkoutManager.updateForStatistics(statistics)
    }
    
    func resetWorkout() {
        hkWorkoutManager.resetWorkout()
    }
    
    func startWorkoutTimer() {
        hkWorkoutManager.startWorkoutTimer()
    }
    
    func stopTimer() {
        hkWorkoutManager.stopTimer()
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        hkWorkoutManager.workoutSession(workoutSession, didChangeTo: toState, from: fromState, date: date)
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        hkWorkoutManager.workoutSession(workoutSession, didFailWithError: error)
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        hkWorkoutManager.workoutBuilderDidCollectEvent(workoutBuilder)
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        hkWorkoutManager.workoutBuilder(workoutBuilder, didCollectDataOf: collectedTypes)
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didEnd workoutActivity: HKWorkoutActivity) {
        hkWorkoutManager.workoutBuilder(workoutBuilder, didEnd: workoutActivity)
    }
    
    // Rest Timer Management
    @MainActor
    func syncRestEndTimeFromSharedStorage() {
        hkWorkoutManager.syncRestEndTimeFromSharedStorage()
    }
    
    /// Begin a rest period and schedule a background-safe update at rest end.
    @MainActor
    func startRest(durationSeconds: Int, session: WorkoutSessionModel, currentExerciseIndex: Int = 0) {
        hkWorkoutManager.startRest(durationSeconds: durationSeconds, session: session, currentExerciseIndex: currentExerciseIndex)
    }
    
    /// Cancel any pending rest and clear countdown from Live Activity.
    @MainActor
    func cancelRest() {
        hkWorkoutManager.cancelRest()
    }
    
    /// Called automatically when the scheduled rest end time is reached.
    @MainActor
    func endRest() {
        hkWorkoutManager.endRest()
    }

    // MARK: LiveActivityManager
    
    var liveActivityViewState: LiveActivityManager.ActivityViewState? {
        liveActivityManager.activityViewState
    }
    
    func startLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool = true,
        currentExerciseIndex: Int = 0,
        restEndsAt: Date? = nil,
        statusMessage: String? = nil
    ) {
        liveActivityManager.startLiveActivity(session: session, isActive: isActive, currentExerciseIndex: currentExerciseIndex, restEndsAt: restEndsAt, statusMessage: statusMessage)
    }

    /// Ensure a Workout Live Activity exists for this session; if found, reuse and update it, otherwise create it
    func ensureLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool = true,
        currentExerciseIndex: Int = 0,
        restEndsAt: Date? = nil,
        statusMessage: String? = nil
    ) {
        liveActivityManager.ensureLiveActivity(session: session, isActive: isActive, currentExerciseIndex: currentExerciseIndex, restEndsAt: restEndsAt, statusMessage: statusMessage)
    }
    
    // swiftlint:disable:next function_parameter_count
    func updateLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?,
        statusMessage: String?,
        totalVolumeKg: Double?,
        elapsedTime: TimeInterval?
    ) {
        liveActivityManager.updateLiveActivity(
            session: session,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndsAt,
            statusMessage: statusMessage,
            totalVolumeKg: totalVolumeKg,
            elapsedTime: elapsedTime
        )
    }
    
    /// Update the Workout Live Activity with latest session progress
    func updateLiveActivity(contentState: WorkoutActivityAttributes.ContentState) {
        liveActivityManager.updateLiveActivity(contentState: contentState)
    }

    /// End the Workout Live Activity
    func endLiveActivity(
        session: WorkoutSessionModel,
        isCompleted: Bool = true,
        statusMessage: String? = nil
    ) {
        liveActivityManager.endLiveActivity(session: session, isCompleted: isCompleted, statusMessage: statusMessage)
    }
    
    func endActivity(with finalState: WorkoutActivityAttributes.ContentState, dismissalPolicy: ActivityUIDismissalPolicy) async {
        await liveActivityManager.endActivity(with: finalState, dismissalPolicy: dismissalPolicy)
    }
    
    func setup(withActivity activity: Activity<WorkoutActivityAttributes>) {
        liveActivityManager.setup(withActivity: activity)
    }
    
    func observeActivity(activity: Activity<WorkoutActivityAttributes>) {
        liveActivityManager.observeActivity(activity: activity)
    }
    
    func updateWorkoutActivity(with updatedState: WorkoutActivityAttributes.ContentState) async throws {
        try await liveActivityManager.updateWorkoutActivity(with: updatedState)
    }
    
    func cleanupDismissedActivity() {
        liveActivityManager.cleanupDismissedActivity()
    }

    /// Update only isActive/rest/status from current content state to avoid recomputing set counts
    func updateRestAndActive(
        isActive: Bool,
        restEndsAt: Date?,
        statusMessage: String? = nil
    ) {
        liveActivityManager.updateRestAndActive(isActive: isActive, restEndsAt: restEndsAt, statusMessage: statusMessage)
    }

    #endif

    // MARK: Haptics

    func prepareHaptic(option: HapticOption) {
        hapticManager.prepare(option: option)
    }

    func playHaptic(option: HapticOption) {
        hapticManager.play(option: option)
    }

    func tearDownHaptic(option: HapticOption) {
        hapticManager.tearDown(option: option)
    }

    // MARK: Sound Effects

    func prepareSoundEffect(sound: SoundEffectFile, simultaneousPlayers: Int = 1) {
        Task {
            await soundEffectManager.prepare(url: sound.url, simultaneousPlayers: simultaneousPlayers, volume: 1)
        }
    }

    func tearDownSoundEffect(sound: SoundEffectFile) {
        Task {
            await soundEffectManager.tearDown(url: sound.url)
        }
    }

    func playSoundEffect(sound: SoundEffectFile) {
        Task {
            await soundEffectManager.play(url: sound.url)
        }
    }

}

// swiftlint:disable:next file_length
enum CoreError: LocalizedError { case noCurrentUser }
