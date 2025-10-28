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

@MainActor
// swiftlint:disable:next type_body_length
struct CoreInteractor {
    private let authManager: AuthManager
    private let userManager: UserManager
    private let purchaseManager: PurchaseManager
    private let exerciseTemplateManager: ExerciseTemplateManager
    private let exerciseUnitPreferenceManager: ExerciseUnitPreferenceManager
    private let workoutTemplateManager: WorkoutTemplateManager
    private let workoutSessionManager: WorkoutSessionManager
    private let exerciseHistoryManager: ExerciseHistoryManager
    private let trainingPlanManager: TrainingPlanManager
    private let programTemplateManager: ProgramTemplateManager
    private let ingredientTemplateManager: IngredientTemplateManager
    private let recipeTemplateManager: RecipeTemplateManager
    private let nutritionManager: NutritionManager
    private let mealLogManager: MealLogManager
    private let pushManager: PushManager
    private let aiManager: AIManager
    private let logManager: LogManager
    private let reportManager: ReportManager
    private let healthKitManager: HealthKitManager
    private let trainingAnalyticsManager: TrainingAnalyticsManager
    private let detailNavigationModel: DetailNavigationModel
    private let userWeightManager: UserWeightManager
    private let goalManager: GoalManager
#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
    private let hkWorkoutManager: HKWorkoutManager
    private let liveActivityManager: LiveActivityManager
#endif
    
    init(
        container: DependencyContainer
    ) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.exerciseUnitPreferenceManager = container.resolve(ExerciseUnitPreferenceManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.exerciseHistoryManager = container.resolve(ExerciseHistoryManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.programTemplateManager = container.resolve(ProgramTemplateManager.self)!
        self.ingredientTemplateManager = container.resolve(IngredientTemplateManager.self)!
        self.recipeTemplateManager = container.resolve(RecipeTemplateManager.self)!
        self.nutritionManager = container.resolve(NutritionManager.self)!
        self.mealLogManager = container.resolve(MealLogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.reportManager = container.resolve(ReportManager.self)!
        self.healthKitManager = container.resolve(HealthKitManager.self)!
        self.trainingAnalyticsManager = container.resolve(TrainingAnalyticsManager.self)!
        self.detailNavigationModel = container.resolve(DetailNavigationModel.self)!
        self.userWeightManager = container.resolve(UserWeightManager.self)!
        self.goalManager = container.resolve(GoalManager.self)!
#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        self.hkWorkoutManager = container.resolve(HKWorkoutManager.self)!
        self.liveActivityManager = container.resolve(LiveActivityManager.self)!
#endif
    }
    
    // MARK: AuthManager
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
    
    func createUser(email: String, password: String) async throws -> UserAuthInfo {
        try await authManager.createUser(email: email, password: password)
    }
    
    func sendVerificationEmail() async throws {
        try await authManager.sendVerificationEmail()
    }
    
    func checkVerificationEmail() async throws -> Bool {
        try await authManager.checkEmailVerification()
    }
    
    func signInUser(email: String, password: String) async throws -> UserAuthInfo {
        try await authManager.signInUser(email: email, password: password)
    }
    
    func resetPassword(email: String) async throws {
        try await authManager.resetPassword(email: email)
    }
    
    func updateEmail(email: String) async throws {
        try await authManager.updateEmail(email: email)
    }
    
    func updatePassword(password: String) async throws {
        try await authManager.updatePassword(password: password)
    }
    
    func reauthenticate(email: String, password: String) async throws {
        try await authManager.reauthenticate(email: email, password: password)
    }
    
    func signInAnonymously() async throws -> UserAuthInfo? {
        try await authManager.signInAnonymously()
    }
    
    func signInApple() async throws -> UserAuthInfo {
        try await authManager.signInApple()
    }
    
    func reauthenticateApple() async throws {
        try await authManager.reauthenticateWithApple()
    }
    
    func signInGoogle() async throws -> UserAuthInfo {
        try await authManager.signInGoogle()
    }
    
    func signOut() throws {
        try authManager.signOut()
    }
    
    func deleteAccount() async throws {
        try await authManager.deleteAccount()
    }
    
    // MARK: UserManager
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    func currentUserId() throws -> String? {
        try userManager.currentUserId()
    }
    
    func refreshProfileImage() async throws {
        try await userManager.refreshProfileImage()
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
        weightUnitPreference: WeightUnitPreference
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
                weightUnitPreference: weightUnitPreference
            )
    }
    
    func logOut() {
        // Stop the sync listener for training plans
        trainingPlanManager.stopSyncListener()
        
        userManager.logOut()
    }
    
    func markUnanonymous(email: String? = nil) async throws {
        try await userManager.markUnanonymous()
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
    func updateHealthConsents(disclaimerVersion: String, privacyVersion: String, acceptedAt: Date = Date()) async throws {
        try await userManager.updateHealthConsents(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion, acceptedAt: acceptedAt)
    }
    
    // User Blocking
    
    func blockUser(userId: String) async throws {
        try await userManager.blockUser(userId: userId)
    }
    
    func unblockUser(userId: String) async throws {
        try await userManager.unblockUser(userId: userId)
    }
    
    // User deletion
    
    func deleteCurrentUser() async throws {
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
    
    // MARK: PurchaseManager
    
    func purchase() async throws {
        try await purchaseManager.purchase()
    }
    
    // MARK: ExerciseTemplateManager
    
    func addLocalExerciseTemplate(exercise: ExerciseTemplateModel) async throws {
        try await exerciseTemplateManager.addLocalExerciseTemplate(exercise: exercise)
    }
    
    func getLocalExerciseTemplate(id: String) throws -> ExerciseTemplateModel {
        try exerciseTemplateManager.getLocalExerciseTemplate(id: id)
    }
    
    func getLocalExerciseTemplates(ids: [String]) throws -> [ExerciseTemplateModel] {
        try exerciseTemplateManager.getLocalExerciseTemplates(ids: ids)
    }
    
    func getAllLocalExerciseTemplates() throws -> [ExerciseTemplateModel] {
        try exerciseTemplateManager.getAllLocalExerciseTemplates()
    }
    
    func getSystemExerciseTemplates() throws -> [ExerciseTemplateModel] {
        try exerciseTemplateManager.getSystemExerciseTemplates()
    }
    
    func createExerciseTemplate(exercise: ExerciseTemplateModel, image: PlatformImage?) async throws {
        try await exerciseTemplateManager.createExerciseTemplate(exercise: exercise, image: image)
    }
    
    func getExerciseTemplate(id: String) async throws -> ExerciseTemplateModel {
        try await exerciseTemplateManager.getExerciseTemplate(id: id)
    }
    
    func getExerciseTemplates(ids: [String], limitTo: Int = 20) async throws -> [ExerciseTemplateModel] {
        try await exerciseTemplateManager.getExerciseTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseTemplateModel] {
        try await exerciseTemplateManager.getExerciseTemplatesByName(name: name)
    }
    
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseTemplateModel] {
        try await exerciseTemplateManager.getExerciseTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopExerciseTemplatesByClicks(limitTo: Int = 10) async throws -> [ExerciseTemplateModel] {
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
    
    var isTrackerPresented: Bool {
        workoutSessionManager.isTrackerPresented
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
    
    func setIsTrackerPresented(_ presented: Bool) {
        workoutSessionManager.isTrackerPresented = presented
    }
    
    func startActiveSession(_ session: WorkoutSessionModel) {
        workoutSessionManager.startActiveSession(session)
    }
    
    func minimizeActiveSession() {
        workoutSessionManager.minimizeActiveSession()
    }
    
    func reopenActiveSession() {
        workoutSessionManager.reopenActiveSession()
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
    
    // MARK: TrainingPlanManager
    
    var currentTrainingPlan: TrainingPlan? {
        trainingPlanManager.currentTrainingPlan
    }
    
    var allPlans: [TrainingPlan] {
        trainingPlanManager.allPlans
    }
    
    @MainActor
    func clearAllTrainingPlanLocalData() throws {
        try trainingPlanManager.clearAllLocalData()
    }
    
    // Plan Management
    
    func createPlan(_ plan: TrainingPlan) async throws {
        try await trainingPlanManager.createPlan(plan)
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
    
    func createBlankPlan(
        name: String,
        userId: String,
        description: String? = nil,
        startDate: Date = .now
    ) async throws -> TrainingPlan {
        try await trainingPlanManager.createBlankPlan(name: name, userId: userId, description: description, startDate: startDate)
    }
    
    func updatePlan(_ plan: TrainingPlan) async throws {
        try await trainingPlanManager.updatePlan(plan)
    }
    
    func deletePlan(id: String) async throws {
        try await trainingPlanManager.deletePlan(id: id)
        
    }
    
    func setActivePlan(_ plan: TrainingPlan) {
        trainingPlanManager.setActivePlan(plan)
    }
    
    // Progress Tracking
    
    func getWeeklyProgress(for weekNumber: Int) -> WeekProgress {
        trainingPlanManager.getWeeklyProgress(for: weekNumber)
    }
    
    func getCurrentWeek() -> TrainingWeek? {
        trainingPlanManager.getCurrentWeek()
    }
    
    func getUpcomingWorkouts(limit: Int = 5) -> [ScheduledWorkout] {
        trainingPlanManager.getUpcomingWorkouts(limit: limit)
    }
    
    func getTodaysWorkouts() -> [ScheduledWorkout] {
        trainingPlanManager.getTodaysWorkouts()
    }
    
    func getAdherenceRate() -> Double {
        trainingPlanManager.getAdherenceRate()
    }
    
    // Goal Management
    
    func addGoal(_ goal: TrainingGoal) async throws {
        try await trainingPlanManager.addGoal(goal)
    }
    
    func updateGoal(_ goal: TrainingGoal) async throws {
        try await trainingPlanManager.updateGoal(goal)
    }
    
    func removeGoal(id: String) async throws {
        try await trainingPlanManager.removeGoal(id: id)
    }
    
    // Smart Suggestions
    
    func suggestNextWeekWorkouts(basedOn currentWeek: TrainingWeek) -> [ScheduledWorkout] {
        trainingPlanManager.suggestNextWeekWorkouts(basedOn: currentWeek)
    }
    
    // Sync Operations
    
    func syncFromRemote() async throws {
        let userId = try userManager.currentUserId()
        try await trainingPlanManager.syncFromRemote(userId: userId)
    }
    
    // MARK: ProgramTemplateManager
    
    var programTemplates: [ProgramTemplateModel] {
        programTemplateManager.templates
    }
    
    func getAll() -> [ProgramTemplateModel] {
        programTemplateManager.getAll()
    }
    
    func get(id: String) -> ProgramTemplateModel? {
        programTemplateManager.get(id: id)
    }
    
    func getBuiltInTemplates() -> [ProgramTemplateModel] {
        programTemplateManager.getBuiltInTemplates()
    }
    
    func create(_ template: ProgramTemplateModel) async throws {
        try await programTemplateManager.create(template)
    }
    
    func update(_ template: ProgramTemplateModel) async throws {
        try await programTemplateManager.update(template)
    }
    
    func delete(id: String) async throws {
        try await programTemplateManager.delete(id: id)
    }
    
    // Sync Operations
    
    func syncProgramTemplatesFromRemote() async throws {
        try await programTemplateManager.syncFromRemote()
    }
    
    func fetchPublicTemplates() async throws -> [ProgramTemplateModel] {
        try await programTemplateManager.fetchPublicTemplates()
    }
    
    func fetchTemplateFromRemote(id: String) async throws -> ProgramTemplateModel {
        try await programTemplateManager.fetchTemplateFromRemote(id: id)
    }
    
    // Template Instantiation
    
    /// Converts a ProgramTemplate into a TrainingPlan ready to be used
    func instantiateTemplate(
        _ template: ProgramTemplateModel,
        for userId: String,
        startDate: Date,
        endDate: Date? = nil,
        planName: String? = nil
    ) -> TrainingPlan {
        programTemplateManager.instantiateTemplate(
            template,
            for: userId,
            startDate: startDate,
            endDate: endDate,
            planName: planName
        )
    }
    
    func templatesByDifficulty(_ difficulty: DifficultyLevel) -> [ProgramTemplateModel] {
        programTemplateManager.templatesByDifficulty(difficulty)
    }
    
    func templatesByFocusArea(_ focusArea: FocusArea) -> [ProgramTemplateModel] {
        programTemplateManager.templatesByFocusArea(focusArea)
    }
    
    // Filtering Helpers
    
    func isBuiltIn(_ template: ProgramTemplateModel) -> Bool {
        programTemplateManager.isBuiltIn(template)
    }
    
    func getUserTemplates(userId: String) -> [ProgramTemplateModel] {
        programTemplateManager.getUserTemplates(userId: userId)
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
    
    func createAndSaveDietPlan(user: UserModel?, configuration: DietPlanConfiguration) async throws {
        try await nutritionManager.createAndSaveDietPlan(user: user, configuration: configuration)
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
        logManager.trackScreenEvent(event: event)
    }
    
    func handleAuthError(_ error: Error, operation: String, provider: String?) -> AuthErrorInfo {
        AuthErrorHandler.handle(error, operation: operation, provider: provider, logManager: logManager)
    }
    
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo {
        AuthErrorHandler.handle(error, operation: operation, provider: nil, logManager: logManager)
    }
    
    func handleUserLoginError(_ error: Error) -> AuthErrorInfo {
        AuthErrorHandler.handleUserLoginError(error, logManager: logManager)
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
    
    // MARK: TrainingAnalyticsManager
    
    var cachedSnapshot: ProgressSnapshot? {
        trainingAnalyticsManager.cachedSnapshot
    }
    
    func getProgressSnapshot(for period: DateInterval) async throws -> ProgressSnapshot {
        try await trainingAnalyticsManager.getProgressSnapshot(for: period)
    }
    
    func getVolumeTrend(for period: DateInterval, interval: Calendar.Component = .weekOfYear) async -> VolumeTrend {
        await trainingAnalyticsManager.getVolumeTrend(for: period, interval: interval)
    }
    
    func getStrengthProgression(for exerciseId: String, in period: DateInterval) async throws -> StrengthProgression? {
        try await trainingAnalyticsManager.getStrengthProgression(for: exerciseId, in: period)
    }
    
    func invalidateCache() {
        trainingAnalyticsManager.invalidateCache()
    }
    
    // MARK: DetailNavigationModel
    
    var path: [NavigationPathOption] {
        detailNavigationModel.path
    }
    
    func clearPath() {
        detailNavigationModel.clear()
    }
    
    // UserWeightManager
    
    var weightHistory: [WeightEntry] {
        userWeightManager.weightHistory
    }
    
    func logWeight(_ weightKg: Double, date: Date = Date(), notes: String? = nil, userId: String) async throws {
        try await userWeightManager.logWeight(weightKg, date: date, notes: notes, userId: userId)
    }
    
    func getWeightHistory(userId: String, limit: Int? = nil) async throws -> [WeightEntry] {
        try await userWeightManager.getWeightHistory(userId: userId, limit: limit)
    }
    
    func getLatestWeight(userId: String) async throws -> WeightEntry? {
        try await userWeightManager.getLatestWeight(userId: userId)
    }
    
    func deleteWeightEntry(id: String, userId: String) async throws {
        try await userWeightManager.deleteWeightEntry(id: id, userId: userId)
    }
    
    func refresh(userId: String) async throws {
        try await userWeightManager.refresh(userId: userId)
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
        objective: String,
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

    /// Update the Workout Live Activity with latest session progress
    func updateLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?,
        statusMessage: String? = nil,
        totalVolumeKg: Double? = nil,
        elapsedTime: TimeInterval? = nil
    ) {
        liveActivityManager.updateLiveActivity(session: session, isActive: isActive, currentExerciseIndex: currentExerciseIndex, restEndsAt: restEndsAt, statusMessage: statusMessage, totalVolumeKg: totalVolumeKg, elapsedTime: elapsedTime)
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
    // swiftlint:disable:next file_length
}
