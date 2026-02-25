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
struct CoreInteractor: GlobalInteractor {
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
    let imageUploadManager: ImageUploadManager
    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
    let hkWorkoutManager: HKWorkoutManager
    let liveActivityManager: LiveActivityManager
    #endif
    let appState: AppState
    let hapticManager: HapticManager
    let soundEffectManager: SoundEffectManager

    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.exerciseUnitPreferenceManager = container.resolve(ExerciseUnitPreferenceManager.self)!
        self.workoutSettingsManager = container.resolve(WorkoutSettingsManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.exerciseHistoryManager = container.resolve(ExerciseHistoryManager.self)!
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
        self.bodyMeasurementsManager = container.resolve(BodyMeasurementsManager.self)!
        self.stepsManager = container.resolve(StepsManager.self)!
        self.goalManager = container.resolve(GoalManager.self)!
        self.imageUploadManager = container.resolve(ImageUploadManager.self)!
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
        logManager.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)
    }

    func signOut() async throws {
        try authManager.signOut()
        try await purchaseManager.logOut()
        userManager.signOut()
    }
    
    func deleteAccount() async throws {
        guard let auth else {
            throw AppError("Auth not found.")
        }
        
        var option: SignInOption = .anonymous
        if auth.authProviders.contains(.apple) {
            option = .apple
        } else if auth.authProviders.contains(.google), let clientId = Constants.firebaseAppClientId {
            option = .google(GIDClientID: clientId)
        }

        // Delete auth
        try await authManager.deleteAccountWithReauthentication(option: option, revokeToken: false) {
            // Delete User profile (Firestore)
            // Note: this must be done within this closure
            // So that it completes before auth is revoked
            // Once auth is revoked, security rules may restrict user from reading/writing to Firestore
            async let deleteExerciseTemplates: () = exerciseTemplateManager.removeAuthorIdFromAllExerciseTemplates(id: auth.uid)
            async let deleteExerciseHistory: () = exerciseHistoryManager.deleteAllLocalExerciseHistoryForAuthor(authorId: auth.uid)
            async let deleteWorkoutTemplates: () = workoutTemplateManager.removeAuthorIdFromAllWorkoutTemplates(id: auth.uid)
            async let deleteWorkoutSessions: () = workoutSessionManager.deleteAllWorkoutSessionsForAuthor(authorId: auth.uid)
            async let deleteRecipeTemplates: () = recipeTemplateManager.removeAuthorIdFromAllRecipeTemplates(id: auth.uid)
            async let deleteIngredientTemplates: () = ingredientTemplateManager.removeAuthorIdFromAllIngredientTemplates(id: auth.uid)
            async let deleteMealLogs: () = mealLogManager.deleteAllMealLogsForAuthor(authorId: auth.uid)
            async let deleteWeightEntries: () = bodyMeasurementsManager.deleteAllWeightEntriesForUser(userId: auth.uid)
            async let deleteStepsEntries: () = stepsManager.deleteAllStepsEntriesForUser(userId: auth.uid)
            async let deleteGoals: () = goalManager.deleteAllGoalsForUser(userId: auth.uid)
            async let deleteUser: () = userManager.deleteCurrentUser()

            _ = try await (
                deleteExerciseTemplates,
                deleteExerciseHistory,
                deleteWorkoutTemplates,
                deleteWorkoutSessions,
                deleteRecipeTemplates,
                deleteIngredientTemplates,
                deleteMealLogs,
                deleteWeightEntries,
                deleteStepsEntries,
                deleteGoals,
                deleteUser
            )
            
        }
        
        // Delete Purchases (RevenueCat)
        try await purchaseManager.logOut()
        
        // Delete logs (Mixpanel)
        logManager.deleteUserProfile()
    }
                            
    func syncAllRemoteDataIfLoggedIn() async {
        guard let userId = auth?.uid else { return }
        let user = userManager.currentUser
        
        try? await workoutSessionManager.syncWorkoutSessionsFromRemote(authorId: userId, limitTo: 100)
        try? await mealLogManager.syncMealsFromRemote(authorId: userId)
        try? await mealLogManager.uploadLocalMealsToRemote(authorId: userId)
        try? await trainingProgramManager.syncTrainingProgramsFromRemote(authorId: userId)
        try? await trainingProgramManager.uploadLocalProgramsToRemote(authorId: userId)
        _ = try? await stepsManager.readAllRemoteStepsEntries(userId: userId, userCreationDate: user?.creationDate)
        _ = try? await bodyMeasurementsManager.readAllRemoteWeightEntries(userId: userId)
        
        NotificationCenter.default.post(name: Constants.remoteDataSyncDidComplete, object: nil)
    }
}

enum CoreError: LocalizedError { case noCurrentUser }
