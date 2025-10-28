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
    
    let remote: RemoteUserService
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
    func currentUserId() throws -> String {
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
                
                // Cache profile image if available
                await cacheProfileImageIfNeeded()
            } catch {
                logManager?.trackEvent(event: Event.saveLocalFail(error: error))
            }
        }
    }
    
    private func cacheProfileImageIfNeeded() async {
        guard let user = currentUser,
              let urlString = user.profileImageUrl,
              !urlString.isEmpty else {
            return
        }
        
        // Check if image is already cached
        if ProfileImageCache.shared.getCachedImage(userId: user.userId) != nil {
            return
        }
        
        // Download and cache the image
        do {
            _ = try await ProfileImageCache.shared.downloadAndCache(from: urlString, userId: user.userId)
            logManager?.trackEvent(eventName: "profile_image_cached", parameters: ["user_id": user.userId])
        } catch {
            logManager?.trackEvent(eventName: "profile_image_cache_failed", parameters: [
                "user_id": user.userId,
                "error": error.localizedDescription
            ])
        }
    }
    
    /// Force refresh the cached profile image from Firebase
    func refreshProfileImage() async throws {
        guard let user = currentUser,
              let urlString = user.profileImageUrl,
              !urlString.isEmpty else {
            return
        }
        
        // Remove old cached image
        ProfileImageCache.shared.removeCachedImage(userId: user.userId)
        
        // Download fresh image
            _ = try await ProfileImageCache.shared.downloadAndCache(from: urlString, userId: user.userId)
            logManager?.trackEvent(eventName: "profile_image_refreshed", parameters: ["user_id": user.userId])
        
    }
    
    func clearAllLocalData() {
        logManager?.trackEvent(event: Event.clearAllLocalData)
        local.clearCurrentUser()
        
        // Clear cached profile images
        if let userId = currentUser?.userId {
            ProfileImageCache.shared.removeCachedImage(userId: userId)
        }
        
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
        
        // Optimistically set current user immediately; stream will keep it updated
        self.currentUser = user
        self.saveCurrentUserLocally()
        
        addCurrentUserListener(userId: auth.uid)
        // Refresh onboarding step from persisted user if available
    }
    
    func saveUser(user: UserModel, image: PlatformImage?) async throws {
        try await remote.saveUser(user: user, image: image)
        
        // Cache the image locally if provided
        if let image = image {
            do {
                try ProfileImageCache.shared.cacheImage(image, userId: user.userId)
                logManager?.trackEvent(eventName: "profile_image_uploaded_and_cached", parameters: ["user_id": user.userId])
            } catch {
                logManager?.trackEvent(eventName: "profile_image_cache_after_upload_failed", parameters: [
                    "user_id": user.userId,
                    "error": error.localizedDescription
                ])
            }
        }
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
    
    func logOut() {
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
    
    func updateWeight(userId: String, weightKg: Double) async throws {
        try await remote.updateWeight(userId: userId, weightKg: weightKg)
        
        // Update local cache
        if var user = currentUser, user.userId == userId {
            user = UserModel(
                userId: user.userId,
                email: user.email,
                isAnonymous: user.isAnonymous,
                firstName: user.firstName,
                lastName: user.lastName,
                dateOfBirth: user.dateOfBirth,
                gender: user.gender,
                heightCentimeters: user.heightCentimeters,
                weightKilograms: weightKg,
                exerciseFrequency: user.exerciseFrequency,
                dailyActivityLevel: user.dailyActivityLevel,
                cardioFitnessLevel: user.cardioFitnessLevel,
                lengthUnitPreference: user.lengthUnitPreference,
                weightUnitPreference: user.weightUnitPreference,
                currentGoalId: user.currentGoalId,
                profileImageUrl: user.profileImageUrl,
                creationDate: user.creationDate,
                creationVersion: user.creationVersion,
                lastSignInDate: user.lastSignInDate,
                didCompleteOnboarding: user.didCompleteOnboarding,
                onboardingStep: user.onboardingStep,
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
            currentUser = user
            saveCurrentUserLocally()
        }
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
        // Monotonic guard: only advance forward
        if let current = currentUser?.onboardingStep, current.orderIndex >= step.orderIndex {
            return
        }
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
    func updateCurrentGoalId(goalId: String?) async throws {
        let uid = try currentUserId()
        try await remote.updateCurrentGoalId(userId: uid, goalId: goalId)
    }
    
    // MARK: - Consents
    func updateHealthConsents(disclaimerVersion: String, privacyVersion: String, acceptedAt: Date = Date()) async throws {
        let uid = try currentUserId()
        try await remote.updateHealthConsents(userId: uid, disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion, acceptedAt: acceptedAt)
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
        logOut()
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
        
        var errorDescription: String? {
            switch self {
            case .noUserId:
                return "No user id available"
            }
        }
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
