//
//  UserManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/14/24.
//

import SwiftUI
import SwiftfulAuthenticating

/// Input for completing account setup: profile fields.
struct CompleteAccountSetupProfileInput {
    let dateOfBirth: Date
    let gender: Gender
    let heightCentimeters: Double
    let weightKilograms: Double
    let exerciseFrequency: ExerciseFrequency
    let dailyActivityLevel: ActivityLevel
    let cardioFitnessLevel: CardioFitnessLevel
    let lengthUnitPreference: LengthUnitPreference
    let weightUnitPreference: WeightUnitPreference
}

@Observable
@MainActor
class UserManager {
    
    let remote: RemoteUserService
    private let local: LocalUserPersistence
    private let logManager: LogManager?
    
    private(set) var currentUser: UserModel?
    private var currentUserListenerTask: Task<Void, Error>?

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
    
    func getUser(userId: String) async throws -> UserModel {
        try await remote.getUser(userId: userId)
    }
    
    func saveOnboardingCompleteForCurrentUser() async throws {
        let uid = try currentUserId()
        try await remote.markOnboardingCompleted(userId: uid)
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
              let urlString = user.submittedProfileImage,
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
              let urlString = user.submittedProfileImage,
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
    
    // User FCM Token
    
    func saveUserFCMToken(token: String) async throws {
        let uid = try currentUserId()
        try await remote.saveUserFCMToken(userId: uid, token: token)
    }

    // MARK: - Remote operations
    // MARK: - User
    
    func logIn(auth: UserAuthInfo, image: PlatformImage? = nil, isNewUser: Bool = false) async throws {
        let creationVersion = isNewUser ? Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String : nil

        // Capture any existing anonymous session before state changes.
        // Only considered anonymous if the UID is different (not the same account re-logging in).
        let previousAnonUser: UserModel? = (currentUser?.isAnonymous == true && currentUser?.userId != auth.uid)
            ? currentUser
            : nil

        if isNewUser {
            let user: UserModel

            if let anonUser = previousAnonUser {
                // Anonymous user signing up via SSO for the first time.
                // Migrate all accumulated onboarding data to the new SSO account
                // rather than starting with a blank profile.
                logManager?.trackEvent(event: Event.migrateAnonUser(fromId: anonUser.userId, toId: auth.uid))
                user = UserModel(
                    userId: auth.uid,
                    email: auth.email ?? anonUser.email,
                    isAnonymous: auth.isAnonymous,
                    authProviders: auth.authProviders.map { $0.rawValue },
                    displayName: auth.displayName ?? anonUser.displayName,
                    firstName: auth.firstName ?? anonUser.firstName,
                    lastName: auth.lastName ?? anonUser.lastName,
                    phoneNumber: auth.phoneNumber ?? anonUser.phoneNumber,
                    photoUrl: auth.photoURL?.absoluteString ?? anonUser.photoUrl,
                    creationDate: auth.creationDate,
                    creationVersion: creationVersion,
                    lastSignInDate: auth.lastSignInDate,
                    submittedEmail: anonUser.submittedEmail,
                    submittedFirstName: anonUser.submittedFirstName,
                    submittedLastName: anonUser.submittedLastName,
                    submittedProfileImage: anonUser.submittedProfileImage,
                    submittedDateOfBirth: anonUser.submittedDateOfBirth,
                    submittedGender: anonUser.submittedGender,
                    submittedHeightCentimeters: anonUser.submittedHeightCentimeters,
                    submittedWeightKilograms: anonUser.submittedWeightKilograms,
                    submittedExerciseFrequency: anonUser.submittedExerciseFrequency,
                    submittedDailyActivityLevel: anonUser.submittedDailyActivityLevel,
                    submittedCardioFitnessLevel: anonUser.submittedCardioFitnessLevel,
                    submittedLengthUnitPreference: anonUser.submittedLengthUnitPreference,
                    submittedWeightUnitPreference: anonUser.submittedWeightUnitPreference,
                    submittedCurrentGoalId: anonUser.submittedCurrentGoalId,
                    submittedActiveTrainingProgramId: anonUser.submittedActiveTrainingProgramId,
                    submittedFavouriteGymProfileId: anonUser.submittedFavouriteGymProfileId,
                    blockedUserIds: anonUser.blockedUserIds,
                    fcmToken: anonUser.fcmToken,
                    didCompleteOnboarding: anonUser.didCompleteOnboarding,
                    acceptedHealthDisclaimerVersion: anonUser.acceptedHealthDisclaimerVersion,
                    acceptedHealthDisclaimerDate: anonUser.acceptedHealthDisclaimerDate,
                    acceptedHealthPrivacyPolicyVersion: anonUser.acceptedHealthPrivacyPolicyVersion,
                    acceptedHealthPrivacyPolicyDate: anonUser.acceptedHealthPrivacyPolicyDate
                )
            } else {
                // Fresh SSO sign-up with no prior anonymous session — create a new profile.
                user = UserModel(auth: auth, creationVersion: creationVersion)
            }

            logManager?.trackEvent(event: Event.logInStart(user: user))
            try await remote.saveUser(user: user)
            logManager?.trackEvent(event: Event.logInSuccess(user: user))

            // Delete the now-orphaned anonymous document after migration succeeds.
            if let anonUser = previousAnonUser {
                Task { try? await remote.deleteUser(userId: anonUser.userId) }
            }

            self.currentUser = user
            self.saveCurrentUserLocally()
            addCurrentUserListener(userId: auth.uid)

        } else {
            // Existing SSO account: fetch their document directly so currentUser reflects
            // the correct account (and userId) before logIn returns.
            logManager?.trackEvent(event: Event.logInStart(user: currentUser))

            let existingUser = try await getUser(userId: auth.uid)
            let authProviders = auth.authProviders.map { $0.rawValue }
            let authPhotoUrl = auth.photoURL?.absoluteString

            var updatedUser = existingUser
            updatedUser.isAnonymous = auth.isAnonymous
            updatedUser.authProviders = authProviders
            updatedUser.email = auth.email ?? existingUser.email
            updatedUser.displayName = auth.displayName ?? existingUser.displayName
            updatedUser.firstName = auth.firstName ?? existingUser.firstName
            updatedUser.lastName = auth.lastName ?? existingUser.lastName
            updatedUser.phoneNumber = auth.phoneNumber ?? existingUser.phoneNumber
            updatedUser.photoUrl = authPhotoUrl ?? existingUser.photoUrl
            updatedUser.lastSignInDate = auth.lastSignInDate ?? existingUser.lastSignInDate

            self.currentUser = updatedUser
            self.saveCurrentUserLocally()

            // Stream keeps currentUser up to date with any subsequent remote changes.
            addCurrentUserListener(userId: auth.uid)

            // Delete the orphaned anonymous document now that we have confirmed
            // the user is signing into a different, pre-existing account.
            if let anonUser = previousAnonUser {
                logManager?.trackEvent(event: Event.deleteAnonDocument(userId: anonUser.userId))
                Task { try? await remote.deleteUser(userId: anonUser.userId) }
            }

            // Persist auth-derived field updates to Firestore.
            Task {
                try? await remote.updateUserAuthState(
                    userId: auth.uid,
                    isAnonymous: auth.isAnonymous,
                    authProviders: authProviders,
                    email: auth.email,
                    displayName: auth.displayName,
                    firstName: auth.firstName,
                    lastName: auth.lastName,
                    phoneNumber: auth.phoneNumber,
                    photoUrl: authPhotoUrl,
                    lastSignInDate: auth.lastSignInDate
                )
            }

            logManager?.trackEvent(event: Event.logInSuccess(user: currentUser))
        }
    }
    
    func saveUser(user: UserModel, image: PlatformImage?) async throws {
        try await remote.saveUser(user: user)

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
    func saveCompleteAccountSetupProfile(_ input: CompleteAccountSetupProfileInput) async throws -> UserModel {
        guard let existing = currentUser else { throw UserManagerError.noUserId }
        let updated = UserModel(
            userId: existing.userId,
            email: existing.email,
            isAnonymous: existing.isAnonymous,
            firstName: existing.firstName,
            lastName: existing.lastName,
            creationDate: existing.creationDate,
            creationVersion: existing.creationVersion,
            lastSignInDate: existing.lastSignInDate,
            submittedProfileImage: existing.submittedProfileImage,
            submittedDateOfBirth: input.dateOfBirth,
            submittedGender: input.gender,
            submittedHeightCentimeters: input.heightCentimeters,
            submittedWeightKilograms: input.weightKilograms,
            submittedExerciseFrequency: input.exerciseFrequency,
            submittedDailyActivityLevel: input.dailyActivityLevel,
            submittedCardioFitnessLevel: input.cardioFitnessLevel,
            submittedLengthUnitPreference: input.lengthUnitPreference,
            submittedWeightUnitPreference: input.weightUnitPreference,
            blockedUserIds: existing.blockedUserIds,
            didCompleteOnboarding: existing.didCompleteOnboarding
        )
        try await remote.saveUser(user: updated)
        return updated
    }
    
    func signOut() {
        currentUserListenerTask?.cancel()
        currentUserListenerTask = nil
        currentUser = nil
        logManager?.trackEvent(event: Event.signOut)
    }

    // MARK: - Personal Info
    
    func updateUserName(firstName: String? = nil, lastName: String? = nil) async throws {
        let uid = try currentUserId()
        try await remote.updateUserName(userId: uid, firstName: firstName, lastName: lastName)
    }
    
    func updateGender(gender: Gender) async throws {
        let uid = try currentUserId()
        try await remote.saveUserGender(userId: uid, gender: gender)
    }

    func updateDateOfBirth(dob: Date) async throws {
        let uid = try currentUserId()
        try await remote.saveUserDateOfBirth(userId: uid, dateOfBirth: dob)
    }

    func updateWeight(userId: String, weightKg: Double) async throws {
        try await remote.saveUserWeightKilograms(userId: userId, weightKg: weightKg)
        
        // Update local cache
        if var user = currentUser, user.userId == userId {
            user = UserModel(
                userId: user.userId,
                email: user.email,
                isAnonymous: user.isAnonymous,
                firstName: user.firstName,
                lastName: user.lastName,
                creationDate: user.creationDate,
                creationVersion: user.creationVersion,
                lastSignInDate: user.lastSignInDate,
                submittedProfileImage: user.submittedProfileImage,
                submittedDateOfBirth: user.submittedDateOfBirth,
                submittedGender: user.submittedGender,
                submittedHeightCentimeters: user.submittedHeightCentimeters,
                submittedWeightKilograms: weightKg,
                submittedExerciseFrequency: user.submittedExerciseFrequency,
                submittedDailyActivityLevel: user.submittedDailyActivityLevel,
                submittedCardioFitnessLevel: user.submittedCardioFitnessLevel,
                submittedLengthUnitPreference: user.submittedLengthUnitPreference,
                submittedWeightUnitPreference: user.submittedWeightUnitPreference,
                submittedCurrentGoalId: user.submittedCurrentGoalId,
                blockedUserIds: user.blockedUserIds,
                didCompleteOnboarding: user.didCompleteOnboarding
            )
            currentUser = user
            saveCurrentUserLocally()
        }
    }
    
    // MARK: - Image URL
    
    func updateProfileImage(image: PlatformImage) async throws {
        let uid = try currentUserId()
        try await remote.saveUserProfileImage(userId: uid, image: image)
    }
    
    // MARK: Update Active Training Program
    
    func updateActiveTrainingProgramId(programId: String?) async throws {
        let uid = try currentUserId()
        guard let activeProgramId = programId else { return }
        try await remote.saveUserActiveTrainingProgramId(userId: uid, activeTrainingProgramId: activeProgramId)
        if currentUser != nil {
            currentUser?.submittedActiveTrainingProgramId = activeProgramId
            saveCurrentUserLocally()
        }
    }

    // MARK: Update Favourite Gym Profile

    func updateFavouriteGymProfileId(profileId: String?) async throws {
        let uid = try currentUserId()
        guard let favouriteGymProfileId = profileId else { return }
        try await remote.saveUserFavouriteGymProfileId(userId: uid, favouriteGymProfileId: favouriteGymProfileId)
        if currentUser != nil {
            currentUser?.submittedFavouriteGymProfileId = favouriteGymProfileId
            saveCurrentUserLocally()
        }
    }
    
    // MARK: - Update Metadata
    
    func updateLastSignInDate() async throws {
        let uid = try currentUserId()
        try await remote.saveUserLastSignInDate(userId: uid)
    }
    
    func updateDidCompleteOnboarding() async throws {
        let uid = try currentUserId()
        try await remote.updateDidCompleteOnboarding(userId: uid)
        logManager?.trackEvent(event: Event.updateDidCompleteOnboarding)
        if var existing = currentUser {
            existing.didCompleteOnboarding = true
            self.currentUser = existing
            self.saveCurrentUserLocally()
        }
    }
    
    // MARK: - Goal Settings
    func updateCurrentGoalId(goalId: String?) async throws {
        let uid = try currentUserId()
        guard let currentGoalId = goalId else { return }
        try await remote.saveUserCurrentGoalId(userId: uid, currentGoalId: currentGoalId)
        if currentUser != nil {
            currentUser?.submittedCurrentGoalId = currentGoalId
            saveCurrentUserLocally()
        }
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
    
    /// Deletes the user profile document and clears local state.
    /// Note: This method only handles user profile deletion. The caller (typically CoreInteractor)
    /// is responsible for orchestrating deletion of related data (workout sessions, exercise history, templates, etc.)
    func deleteCurrentUser() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        
        let uid = try currentUserId()

        // Remove the user profile document
        try await remote.deleteUser(userId: uid)

        // Clear local cache/state
        self.clearAllLocalData()
        logManager?.trackEvent(event: Event.deleteAccountSuccess)

        // Reset UserManager state (does not sign out Auth)
        signOut()
    }
    
    // MARK: - User Streaming
    
    private func addCurrentUserListener(userId: String) {
        logManager?.trackEvent(event: Event.remoteListenerStart)

        currentUserListenerTask?.cancel()
        currentUserListenerTask = Task {
            do {
                for try await value in remote.streamUser(userId: userId) {
                    self.currentUser = value
                    logManager?.trackEvent(event: Event.remoteListenerSuccess(user: value))
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                    
                    self.saveCurrentUserLocally()
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
}

extension UserManager {
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
        case updateDidCompleteOnboarding
        case migrateAnonUser(fromId: String, toId: String)
        case deleteAnonDocument(userId: String)

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
            case .clearAllLocalData:            return "UserMan_ClearAllLocalData"
            case .updateDidCompleteOnboarding:  return "UserMan_UpdateDidCompleteOnboarding"
            case .migrateAnonUser:              return "UserMan_MigrateAnonUser"
            case .deleteAnonDocument:           return "UserMan_DeleteAnonDocument"
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
            case .updateDidCompleteOnboarding:
                return nil
            case .migrateAnonUser(fromId: let fromId, toId: let toId):
                return ["from_user_id": fromId, "to_user_id": toId]
            case .deleteAnonDocument(userId: let userId):
                return ["anon_user_id": userId]
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

extension CoreInteractor {
    // MARK: UserManager
    
    func setActiveTrainingProgram(programId: String) async throws {
        try await userManager.updateActiveTrainingProgramId(programId: programId)
    }

    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    var userId: String? {
        userManager.currentUser?.userId
    }
    
    func currentUserId() throws -> String? {
        try userManager.currentUserId()
    }
    
    func refreshProfileImage() async throws {
        try await userManager.refreshProfileImage()
    }

    var userImageUrl: String? {
        currentUser?.submittedProfileImage
    }

    func clearAllLocalData() {
        userManager.clearAllLocalData()
    }
    
    func saveUser(user: UserModel, image: PlatformImage? = nil) async throws {
        try await userManager.saveUser(user: user, image: image)
    }
    
    func saveCompleteAccountSetupProfile(_ input: CompleteAccountSetupProfileInput) async throws -> UserModel {
        try await userManager.saveCompleteAccountSetupProfile(input)
    }
            
    func updateFirstName(firstName: String? = nil, lastName: String? = nil) async throws {
        try await userManager.updateUserName(firstName: firstName)
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
    
    func updateProfileImageUrl(image: PlatformImage) async throws {
        try await userManager.updateProfileImage(image: image)
    }
    
    // Active Training Program
    
    func updateActiveTrainingProgramId(programId: String?) async throws {
        try await userManager.updateActiveTrainingProgramId(programId: programId)
    }
    
    // Favourite Gym Profile
    
    func updateFavouriteGymProfileId(profileId: String?) async throws {
        try await userManager.updateFavouriteGymProfileId(profileId: profileId)
    }
    
    // FCM Token
    
    func saveUserFCMToken(token: String) async throws {
        try await userManager.saveUserFCMToken(token: token)
    }

    // Update Metadata
    
    func updateLastSignInDate() async throws {
        try await userManager.updateLastSignInDate()
    }
    
    func updateDidCompleteOnboarding() async throws {
        try await userManager.updateDidCompleteOnboarding()
    }
    
    func saveOnboardingComplete() async throws {
        try await userManager.saveOnboardingCompleteForCurrentUser()
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

}
