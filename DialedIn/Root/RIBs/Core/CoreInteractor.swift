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
    let imageUploadManager: ImageUploadManager
    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
    let hkWorkoutManager: HKWorkoutManager
    let liveActivityManager: LiveActivityManager
    #endif
    let streakManager: StreakManager
    let commentsManager: CommentsManager
    let activityNotificationManager: ActivityNotificationManager
    let stravaManager: StravaManager
    let appState: AppState
    let hapticManager: HapticManager
    let soundEffectManager: SoundEffectManager

    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
        self.exerciseModelManager = container.resolve(ExerciseModelManager.self)!
        self.exerciseUnitPreferenceManager = container.resolve(ExerciseUnitPreferenceManager.self)!
        self.workoutSettingsManager = container.resolve(WorkoutSettingsManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.trainingProgramManager = container.resolve(TrainingProgramManager.self)!
        self.gymProfileManager = container.resolve(GymProfileManager.self)!
        self.foodManager = container.resolve(FoodManager.self)!
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
        self.streakManager = container.resolve(StreakManager.self)!
        self.commentsManager = container.resolve(CommentsManager.self)!
        self.activityNotificationManager = container.resolve(ActivityNotificationManager.self)!
        self.stravaManager = container.resolve(StravaManager.self)!
        self.appState = container.resolve(AppState.self)!

        self.hapticManager = container.resolve(HapticManager.self)!
        self.soundEffectManager = container.resolve(SoundEffectManager.self)!
    }

    // MARK: Shared
    
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.signIn(auth: user, isNewUser: isNewUser)
        async let workoutSettingsSignIn: () = workoutSettingsManager.signIn(userId: user.uid)
        async let stepsSignIn: () = stepsManager.signIn()
        async let workoutTemplatesSignIn: () = workoutTemplateManager.signIn()
        async let gymProfileSignIn: () = gymProfileManager.signIn()
        async let trainingProgramSignIn: () = trainingProgramManager.signIn(programId: userManager.currentUser?.submittedActiveTrainingProgramId ?? "")
        let followingIds = userManager.currentUser?.followingIds ?? []
        async let workoutSessionSignIn: () = workoutSessionManager.signIn(userId: user.uid, followingIds: followingIds)
        async let followingUsersSignIn: () = userManager.refreshFollowingUsers(followingIds: followingIds)
        async let exerciseSignIn: () = exerciseModelManager.signIn(userId: user.uid)
        async let recipeTemplatesSignIn: () = recipeTemplateManager.signIn()
        async let foodsSignIn: () = foodManager.signIn()
        async let nutritionSignIn: () = nutritionManager.signIn(dietPlanId: user.uid)
        async let mealLogSignIn: () = mealLogManager.signIn(userId: user.uid)
        async let bodyMeasurementsSignIn: () = bodyMeasurementsManager.signIn(userId: user.uid)
        async let goalSignIn: () = goalManager.signIn(userId: user.uid)
        async let streakSignIn: () = streakManager.logIn(userId: user.uid)

        try await workoutSettingsSignIn
        await trainingProgramSignIn
        try await nutritionSignIn
        try await goalSignIn
        await stepsSignIn
        await workoutTemplatesSignIn
        await gymProfileSignIn
        await workoutSessionSignIn
        await followingUsersSignIn
        await exerciseSignIn
        await recipeTemplatesSignIn
        await foodsSignIn
        await mealLogSignIn
        await bodyMeasurementsSignIn
        try await streakSignIn

        // Seed system content after all sync engines have started listening,
        // so local persistence is loaded and allExercises is populated before
        // workout templates try to resolve exercises by ID.
        try? exerciseModelManager.seedExercisesIfNeeded()
        try? workoutTemplateManager.seedWorkoutTemplatesIfNeeded(exercises: exerciseModelManager.allExercises)

        try await purchaseManager.logIn(
            userId: user.uid,
            userAttributes: PurchaseProfileAttributes(
                email: user.email,
                mixpanelDistinctId: Constants.mixpanelDistinctId,
                firebaseAppInstanceId: Constants.firebaseAnalyticsAppInstanceID
            )
        )
        logManager.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)

        activityNotificationManager.startListening(userId: user.uid)
    }

    func signOut() async throws {
        try authManager.signOut()
        try await purchaseManager.logOut()
        userManager.signOut()
        stepsManager.signOut()
        workoutTemplateManager.signOut()
        workoutSessionManager.signOut()
        gymProfileManager.signOut()
        trainingProgramManager.signOut()
        exerciseModelManager.signOut()
        workoutSettingsManager.signOut()
        recipeTemplateManager.signOut()
        foodManager.signOut()
        nutritionManager.signOut()
        mealLogManager.signOut()
        bodyMeasurementsManager.signOut()
        goalManager.signOut()
        streakManager.logOut()
        activityNotificationManager.stopListening()
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
            async let deleteExerciseModels: () = exerciseModelManager.deleteAllExercises()
            async let deleteWorkoutTemplates: () = workoutTemplateManager.deleteAllWorkoutTemplateForAuthor()
            async let deleteWorkoutSessions: () = workoutSessionManager.deleteAllWorkoutSessionsForAuthor(authorId: auth.uid)
            async let deleteRecipeTemplates: () = recipeTemplateManager.deleteAllRecipeTemplates()
            async let deleteFoods: () = foodManager.deleteAllFoods(id: auth.uid)
            async let deleteMealLogs: () = mealLogManager.deleteAllMealLogsForAuthor(authorId: auth.uid)
            async let deleteWeightEntries: () = bodyMeasurementsManager.deleteAllWeightEntriesForUser()
            async let deleteStepsEntries: () = stepsManager.signOut()
            async let deleteGoals: () = goalManager.deleteGoal()
            async let deleteUser: () = userManager.deleteCurrentUser()

            _ = try await (
                deleteExerciseModels,
                deleteWorkoutTemplates,
                deleteWorkoutSessions,
                deleteRecipeTemplates,
                deleteFoods,
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
    
    func startWorkout(for template: WorkoutTemplateModel, in trainingProgramId: String?) async throws {
        guard let userId = self.userId else { throw CoreError.noCurrentUser }
        var unitPreferences: [String: ExerciseUnitPreference] = [:]
        for exerciseModel in template.exercises {
            let preference = self.getPreference(templateId: exerciseModel.exercise.id)
            unitPreferences[exerciseModel.exercise.id] = preference
        }
        let previousSession = try await self.workoutSessionManager.getLastWorkoutSessionForTemplate(templateId: template.id)
        
        let session = WorkoutSessionModel(
            authorId: userId,
            template: template,
            notes: nil,
            trainingProgramId: trainingProgramId,
            previousWorkoutSession: previousSession,
            unitPreferences: unitPreferences
        )
        
        try self.updateActiveSession(session)
        hkWorkoutManager.startWorkout(workout: session)
        ensureLiveActivity(session: session)
    }
    
    func deleteActiveSession() throws {
        try workoutSessionManager.deleteActiveSession()
        hkWorkoutManager.discardWorkout()
    }
                            
    func syncAllRemoteDataIfLoggedIn() async {
        NotificationCenter.default.post(name: Constants.remoteDataSyncDidComplete, object: nil)
    }
}

enum CoreError: LocalizedError { case noCurrentUser }
