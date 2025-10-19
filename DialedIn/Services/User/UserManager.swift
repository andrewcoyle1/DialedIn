//
//  UserManager.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/14/24.
//
import SwiftUI
import SwiftfulUtilities

@MainActor
@Observable
class UserManager {
    
    private let remote: RemoteUserService
    private let local: LocalUserPersistence
    private let logManager: LogManager?
    
    private(set) var currentUser: UserModel?
    private var currentUserListener: (() -> Void)?
    
    init(services: UserServices, logManager: LogManager? = nil) {
        self.remote = services.remote
        self.local = services.local
        self.logManager = logManager
        self.currentUser = local.getCurrentUser()
    }
    
    // MARK: - Local operations
    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }
    
    private func saveCurrentUserLocally() {
        logManager?.trackEvent(event: Event.saveLocalStart(user: currentUser))
        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
                logManager?.trackEvent(event: Event.saveLocalSuccess(user: currentUser))
            } catch {
                logManager?.trackEvent(event: Event.saveLocalFail(error: error))
            }
        }
    }
    
    func clearAllLocalData() {
        logManager?.trackEvent(event: Event.clearAllLocalData)
        local.clearCurrentUser()
        currentUser = nil
    }
    
    // MARK: - Remote operations
    // MARK: - User
    
    func logIn(auth: UserAuthInfo, image: PlatformImage? = nil) async throws {
        let creationVersion = auth.isNewUser ? SwiftfulUtilities.Utilities.appVersion : nil
        var user = UserModel(auth: auth, creationVersion: creationVersion)
        // Only initialize onboarding step for brand new users; otherwise preserve existing remote value
        if auth.isNewUser {
            user = UserModel(
                userId: user.userId,
                email: user.email,
                isAnonymous: user.isAnonymous,
                firstName: user.firstName,
                lastName: user.lastName,
                dateOfBirth: user.dateOfBirth,
                gender: user.gender,
                heightCentimeters: user.heightCentimeters,
                weightKilograms: user.weightKilograms,
                exerciseFrequency: user.exerciseFrequency,
                dailyActivityLevel: user.dailyActivityLevel,
                cardioFitnessLevel: user.cardioFitnessLevel,
                lengthUnitPreference: user.lengthUnitPreference,
                weightUnitPreference: user.weightUnitPreference,
                profileImageUrl: user.profileImageUrl,
                creationDate: user.creationDate,
                creationVersion: user.creationVersion,
                lastSignInDate: user.lastSignInDate,
                didCompleteOnboarding: false,
                onboardingStep: .subscription,
                createdExerciseTemplateIds: user.createdExerciseTemplateIds,
                bookmarkedExerciseTemplateIds: user.bookmarkedExerciseTemplateIds,
                favouritedExerciseTemplateIds: user.favouritedExerciseTemplateIds,
                createdWorkoutTemplateIds: user.createdWorkoutTemplateIds,
                bookmarkedWorkoutTemplateIds: user.bookmarkedWorkoutTemplateIds,
                favouritedWorkoutTemplateIds: user.favouritedWorkoutTemplateIds,
                createdIngredientTemplateIds: user.createdIngredientTemplateIds,
                bookmarkedIngredientTemplateIds: user.bookmarkedIngredientTemplateIds,
                favouritedIngredientTemplateIds: user.favouritedIngredientTemplateIds,
                createdRecipeTemplateIds: user.createdRecipeTemplateIds,
                bookmarkedRecipeTemplateIds: user.bookmarkedRecipeTemplateIds,
                favouritedRecipeTemplateIds: user.favouritedRecipeTemplateIds,
                blockedUserIds: user.blockedUserIds
            )
        }
        logManager?.trackEvent(event: Event.logInStart(user: user))
        try await remote.saveUser(user: user, image: image)
        logManager?.trackEvent(event: Event.logInSuccess(user: user))
        
        addCurrentUserListener(userId: auth.uid)
        // Refresh onboarding step from persisted user if available
    }
    
    func saveUser(user: UserModel, image: PlatformImage?) async throws {
        try await remote.saveUser(user: user, image: image)
    
    }
    
    // MARK: - Onboarding: Complete Account Setup
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
        guard let existing = currentUser else { throw UserManagerError.noUserId }
        let updated = UserModel(
            userId: existing.userId,
            email: existing.email,
            isAnonymous: existing.isAnonymous,
            firstName: existing.firstName,
            lastName: existing.lastName,
            dateOfBirth: dateOfBirth,
            gender: gender,
            heightCentimeters: heightCentimeters,
            weightKilograms: weightKilograms,
            exerciseFrequency: exerciseFrequency,
            dailyActivityLevel: dailyActivityLevel,
            cardioFitnessLevel: cardioFitnessLevel,
            lengthUnitPreference: lengthUnitPreference,
            weightUnitPreference: weightUnitPreference,
            profileImageUrl: existing.profileImageUrl,
            creationDate: existing.creationDate,
            creationVersion: existing.creationVersion,
            lastSignInDate: existing.lastSignInDate,
            didCompleteOnboarding: existing.didCompleteOnboarding,
            createdExerciseTemplateIds: existing.createdExerciseTemplateIds,
            bookmarkedExerciseTemplateIds: existing.bookmarkedExerciseTemplateIds,
            favouritedExerciseTemplateIds: existing.favouritedExerciseTemplateIds,
            createdWorkoutTemplateIds: existing.createdWorkoutTemplateIds,
            bookmarkedWorkoutTemplateIds: existing.bookmarkedWorkoutTemplateIds,
            favouritedWorkoutTemplateIds: existing.favouritedWorkoutTemplateIds,
            createdIngredientTemplateIds: existing.createdIngredientTemplateIds,
            bookmarkedIngredientTemplateIds: existing.bookmarkedIngredientTemplateIds,
            favouritedIngredientTemplateIds: existing.favouritedIngredientTemplateIds,
            createdRecipeTemplateIds: existing.createdRecipeTemplateIds,
            bookmarkedRecipeTemplateIds: existing.bookmarkedRecipeTemplateIds,
            favouritedRecipeTemplateIds: existing.favouritedRecipeTemplateIds,
            blockedUserIds: existing.blockedUserIds
        )
        try await remote.saveUser(user: updated, image: nil)
        return updated
    }
    
    func signOut() {
        currentUserListener?()
        currentUserListener = nil
        currentUser = nil
        self.clearAllLocalData()
        logManager?.trackEvent(event: Event.signOut)
    }
    
    // MARK: - Anonymity/Email
    
    func markUnanonymous(email: String? = nil) async throws {
        let uid = try currentUserId()
        try await remote.markUnanonymous(userId: uid, email: email)
    }
    
    // MARK: - Personal Info
    
    func updateFirstName(firstName: String) async throws {
        let uid = try currentUserId()
        try await remote.updateFirstName(userId: uid, firstName: firstName)
    }
    
    func updateLastName(lastName: String) async throws {
        let uid = try currentUserId()
        try await remote.updateLastName(userId: uid, lastName: lastName)
    }
    
    func updateDateOfBirth(dob: Date) async throws {
        let uid = try currentUserId()
        try await remote.updateDateOfBirth(userId: uid, dateOfBirth: dob)
    }
    
    func updateGender(gender: Gender) async throws {
        let uid = try currentUserId()
        try await remote.updateGender(userId: uid, gender: gender)
    }
    
    // MARK: - Image URL
    
    func updateProfileImageUrl(url: String?) async throws {
        let uid = try currentUserId()
        try await remote.updateProfileImageUrl(userId: uid, url: url)
    }

    // MARK: - Update Metadata
    
    func updateLastSignInDate() async throws {
        let uid = try currentUserId()
        try await remote.updateLastSignInDate(userId: uid)
    }
    
    func updateOnboardingStep(step: OnboardingStep) async throws {
        let uid = try currentUserId()
        try await remote.updateOnboardingStep(userId: uid, step: step)
        // Optimistically update local cache so routing on app relaunch restores to the latest step
        if let existing = currentUser {
            let updated = UserModel(
                userId: existing.userId,
                email: existing.email,
                isAnonymous: existing.isAnonymous,
                firstName: existing.firstName,
                lastName: existing.lastName,
                dateOfBirth: existing.dateOfBirth,
                gender: existing.gender,
                heightCentimeters: existing.heightCentimeters,
                weightKilograms: existing.weightKilograms,
                exerciseFrequency: existing.exerciseFrequency,
                dailyActivityLevel: existing.dailyActivityLevel,
                cardioFitnessLevel: existing.cardioFitnessLevel,
                lengthUnitPreference: existing.lengthUnitPreference,
                weightUnitPreference: existing.weightUnitPreference,
                profileImageUrl: existing.profileImageUrl,
                creationDate: existing.creationDate,
                creationVersion: existing.creationVersion,
                lastSignInDate: existing.lastSignInDate,
                didCompleteOnboarding: step == .complete ? true : existing.didCompleteOnboarding,
                onboardingStep: step,
                createdExerciseTemplateIds: existing.createdExerciseTemplateIds,
                bookmarkedExerciseTemplateIds: existing.bookmarkedExerciseTemplateIds,
                favouritedExerciseTemplateIds: existing.favouritedExerciseTemplateIds,
                createdWorkoutTemplateIds: existing.createdWorkoutTemplateIds,
                bookmarkedWorkoutTemplateIds: existing.bookmarkedWorkoutTemplateIds,
                favouritedWorkoutTemplateIds: existing.favouritedWorkoutTemplateIds,
                createdIngredientTemplateIds: existing.createdIngredientTemplateIds,
                bookmarkedIngredientTemplateIds: existing.bookmarkedIngredientTemplateIds,
                favouritedIngredientTemplateIds: existing.favouritedIngredientTemplateIds,
                createdRecipeTemplateIds: existing.createdRecipeTemplateIds,
                bookmarkedRecipeTemplateIds: existing.bookmarkedRecipeTemplateIds,
                favouritedRecipeTemplateIds: existing.favouritedRecipeTemplateIds,
                blockedUserIds: existing.blockedUserIds
            )
            self.currentUser = updated
            self.saveCurrentUserLocally()
        }
    }
    
    // MARK: - Goal Settings
    func updateGoalSettings(objective: String, targetWeightKilograms: Double, weeklyChangeKilograms: Double) async throws {
        let uid = try currentUserId()
        try await remote.updateGoalSettings(userId: uid, objective: objective, targetWeightKilograms: targetWeightKilograms, weeklyChangeKilograms: weeklyChangeKilograms)
    }
    
    // MARK: - Consents
    func updateHealthConsents(disclaimerVersion: String, privacyVersion: String, acceptedAt: Date = Date()) async throws {
        let uid = try currentUserId()
        try await remote.updateHealthConsents(userId: uid, disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion, acceptedAt: acceptedAt)
    }
    
    // MARK: - Created/Bookmarked/Favourited Exercise Templates
    
    func addCreatedExerciseTemplate(exerciseId: String) async throws {
        let uid = try currentUserId()
        try await remote.addCreatedExerciseTemplate(userId: uid, exerciseTemplateId: exerciseId)
    }
    
    func removeCreatedExerciseTemplate(exerciseId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeCreatedExerciseTemplate(userId: uid, exerciseTemplateId: exerciseId)
    }
    
    func addBookmarkedExerciseTemplate(exerciseId: String) async throws {
        let uid = try currentUserId()
        try await remote.addBookmarkedExerciseTemplate(userId: uid, exerciseTemplateId: exerciseId)
    }
    
    func removeBookmarkedExerciseTemplate(exerciseId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeBookmarkedExerciseTemplate(userId: uid, exerciseTemplateId: exerciseId)
    }
    
    func addFavouritedExerciseTemplate(exerciseId: String) async throws {
        let uid = try currentUserId()
        try await remote.addFavouritedExerciseTemplate(userId: uid, exerciseTemplateId: exerciseId)
    }
    
    func removeFavouritedExerciseTemplate(exerciseId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeFavouritedExerciseTemplate(userId: uid, exerciseTemplateId: exerciseId)
    }
    
    // MARK: - Created/Bookmarked/Favourited Workout Templates
    
    func addCreatedWorkoutTemplate(workoutId: String) async throws {
        let uid = try currentUserId()
        try await remote.addCreatedWorkoutTemplate(userId: uid, workoutTemplateId: workoutId)
    }
    
    func removeCreatedWorkoutTemplate(workoutId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeCreatedWorkoutTemplate(userId: uid, workoutTemplateId: workoutId)
    }
    
    func addBookmarkedWorkoutTemplate(workoutId: String) async throws {
        let uid = try currentUserId()
        try await remote.addBookmarkedWorkoutTemplate(userId: uid, workoutTemplateId: workoutId)
    }
    
    func removeBookmarkedWorkoutTemplate(workoutId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeBookmarkedWorkoutTemplate(userId: uid, workoutTemplateId: workoutId)
    }
    
    func addFavouritedWorkoutTemplate(workoutId: String) async throws {
        let uid = try currentUserId()
        try await remote.addFavouritedWorkoutTemplate(userId: uid, workoutTemplateId: workoutId)
    }
    
    func removeFavouritedWorkoutTemplate(workoutId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeFavouritedWorkoutTemplate(userId: uid, workoutTemplateId: workoutId)
    }
    
    // MARK: - Created/Bookmarked/Favourited Ingredient Templates

    func addCreatedIngredientTemplate(ingredientId: String) async throws {
        let uid = try currentUserId()
        try await remote.addCreatedIngredientTemplate(userId: uid, ingredientTemplateId: ingredientId)
    }

    func removeCreatedIngredientTemplate(ingredientId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeCreatedIngredientTemplate(userId: uid, ingredientTemplateId: ingredientId)
    }

    func addBookmarkedIngredientTemplate(ingredientId: String) async throws {
        let uid = try currentUserId()
        try await remote.addBookmarkedIngredientTemplate(userId: uid, ingredientTemplateId: ingredientId)
    }

    func removeBookmarkedIngredientTemplate(ingredientId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeBookmarkedIngredientTemplate(userId: uid, ingredientTemplateId: ingredientId)
    }

    func addFavouritedIngredientTemplate(ingredientId: String) async throws {
        let uid = try currentUserId()
        try await remote.addFavouritedIngredientTemplate(userId: uid, ingredientTemplateId: ingredientId)
    }

    func removeFavouritedIngredientTemplate(ingredientId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeFavouritedIngredientTemplate(userId: uid, ingredientTemplateId: ingredientId)
    }

    // MARK: - Created/Bookmarked/Favourited Recipe Templates

    func addCreatedRecipeTemplate(recipeId: String) async throws {
        let uid = try currentUserId()
        try await remote.addCreatedRecipeTemplate(userId: uid, recipeTemplateId: recipeId)
    }

    func removeCreatedRecipeTemplate(recipeId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeCreatedRecipeTemplate(userId: uid, recipeTemplateId: recipeId)
    }

    func addBookmarkedRecipeTemplate(recipeId: String) async throws {
        let uid = try currentUserId()
        try await remote.addBookmarkedRecipeTemplate(userId: uid, recipeTemplateId: recipeId)
    }

    func removeBookmarkedRecipeTemplate(recipeId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeBookmarkedRecipeTemplate(userId: uid, recipeTemplateId: recipeId)
    }

    func addFavouritedRecipeTemplate(recipeId: String) async throws {
        let uid = try currentUserId()
        try await remote.addFavouritedRecipeTemplate(userId: uid, recipeTemplateId: recipeId)
    }

    func removeFavouritedRecipeTemplate(recipeId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeFavouritedRecipeTemplate(userId: uid, recipeTemplateId: recipeId)
    }
    
    // MARK: - User Blocking
    
    func blockUser(userId: String) async throws {
        let uid = try currentUserId()
        try await remote.blockUser(currentUserId: uid, blockedUserId: userId)
    }
    
    func unblockUser(userId: String) async throws {
        let uid = try currentUserId()
        try await remote.unblockUser(currentUserId: uid, blockedUserId: userId)
    }
    
    // MARK: - User deletion
    
    func deleteCurrentUser() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        
        let uid = try currentUserId()

        // 1) Delete/anonymize LOCAL data first (best-effort)
        do {
            let workoutSessions = WorkoutSessionManager(services: ProductionWorkoutSessionServices())
            try workoutSessions.deleteAllLocalWorkoutSessionsForAuthor(authorId: uid)
        } catch { /* ignore local errors */ }
        do {
            let exerciseHistory = ExerciseHistoryManager(services: ProductionExerciseHistoryServices())
            try exerciseHistory.deleteAllLocalExerciseHistoryForAuthor(authorId: uid)
        } catch { /* ignore local errors */ }

        // 2) Delete/anonymize REMOTE data in parallel while auth is still valid
        try await withThrowingTaskGroup(of: Void.self) { group in
            // Profile image in Storage (best-effort; ignore if missing)
            let exerciseTemplateManager = ExerciseTemplateManager(services: ProductionExerciseTemplateServices())
            group.addTask {
                do {
                    try await FirebaseImageUploadService().deleteImage(path: "users/\(uid)/profile.jpg")
                } catch {
                    /* ignore storage deletion errors */
                }
            }
            // Workout Sessions
            group.addTask {
                let manager = await WorkoutSessionManager(services: ProductionWorkoutSessionServices())
                try await manager.deleteAllWorkoutSessionsForAuthor(authorId: uid)
            }
            // Exercise History
            group.addTask {
                let manager = await ExerciseHistoryManager(services: ProductionExerciseHistoryServices())
                try await manager.deleteAllExerciseHistoryForAuthor(authorId: uid)
            }
            // Templates: remove author_id to anonymize authored content
            group.addTask {
                let manager = await ExerciseTemplateManager(services: ProductionExerciseTemplateServices())
                try await manager.removeAuthorIdFromAllExerciseTemplates(id: uid)
            }
            group.addTask {
                let manager = await WorkoutTemplateManager(services: ProductionWorkoutTemplateServices(exerciseManager: exerciseTemplateManager), exerciseManager: exerciseTemplateManager)
                try await manager.removeAuthorIdFromAllWorkoutTemplates(id: uid)
            }
            group.addTask {
                let manager = await IngredientTemplateManager(services: ProductionIngredientTemplateServices())
                try await manager.removeAuthorIdFromAllIngredientTemplates(id: uid)
            }
            group.addTask {
                let manager = await RecipeTemplateManager(services: ProductionRecipeTemplateServices())
                try await manager.removeAuthorIdFromAllRecipeTemplates(id: uid)
            }
            try await group.waitForAll()
        }

        // 3) Remove the user profile document
        try await remote.deleteUser(userId: uid)

        // 4) Clear local cache/state
        self.clearAllLocalData()
        logManager?.trackEvent(event: Event.deleteAccountSuccess)

        // 5) Reset UserManager state (does not sign out Auth)
        signOut()
    }
    
    // MARK: - User Streaming
    
    private func addCurrentUserListener(userId: String) {
        currentUserListener?()
        logManager?.trackEvent(event: Event.remoteListenerStart)
        
        Task {
            do {
                for try await value in remote.streamUser(userId: userId) {
                    self.currentUser = value
                    logManager?.trackEvent(event: Event.remoteListenerSuccess(user: value))
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                    self.saveCurrentUserLocally()
                    // Keep local onboarding step coherent with user properties if needed
                }
            } catch {
                logManager?.trackEvent(event: Event.remoteListenerFail(error: error))
            }
        }
    }
    
    enum UserManagerError: LocalizedError {
        case noUserId
    }
    
    enum Event: LoggableEvent {
        case logInStart(user: UserModel?)
        case logInSuccess(user: UserModel?)
        case remoteListenerStart
        case remoteListenerSuccess(user: UserModel?)
        case remoteListenerFail(error: Error)
        case saveLocalStart(user: UserModel?)
        case saveLocalSuccess(user: UserModel?)
        case saveLocalFail(error: Error)
        case signOut
        case deleteAccountStart
        case deleteAccountSuccess
        case clearAllLocalData
        
        var eventName: String {
            switch self {
            case .logInStart:               return "UserMan_LogIn_Start"
            case .logInSuccess:             return "UserMan_LogIn_Success"
            case .remoteListenerStart:      return "UserMan_RemoteListener_Start"
            case .remoteListenerSuccess:    return "UserMan_RemoteListener_Success"
            case .remoteListenerFail:       return "UserMan_RemoteListener_Fail"
            case .saveLocalStart:           return "UserMan_SaveLocal_Start"
            case .saveLocalSuccess:         return "UserMan_SaveLocal_Success"
            case .saveLocalFail:            return "UserMan_SaveLocal_Fail"
            case .signOut:                  return "UserMan_SignOut"
            case .deleteAccountStart:       return "UserMan_DeleteAccount_Start"
            case .deleteAccountSuccess:     return "UserMan_DeleteAccount_Success"
            case .clearAllLocalData:        return "UserMan_ClearAllLocalData"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .logInStart(user: let user), .logInSuccess(user: let user),
                    .remoteListenerSuccess(user: let user), .saveLocalStart(user: let user),
                    .saveLocalSuccess(user: let user):
                return user?.eventParameters
            case .remoteListenerFail(error: let error), .saveLocalFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .remoteListenerFail, .saveLocalFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}
