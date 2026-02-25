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
    
    /// Log In
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        if isNewUser {
            // New user: create their Firestore document from auth data.
            let user = UserModel(auth: auth, creationVersion: Utilities.appVersion)
            logManager?.trackEvent(event: Event.logInStart(user: user))
            try await remote.saveUser(user: user)
            self.currentUser = user
            logManager?.trackEvent(event: Event.logInSuccess(user: user))
        } else {
            // Returning user: fetch their existing document so currentUser is correct
            // before any routing decisions are made. Writing an auth-only stub would
            // overwrite non-optional fields like didCompleteOnboarding with defaults.
            logManager?.trackEvent(event: Event.logInStart(user: currentUser))
            let storedUser = try await remote.getUser(userId: auth.uid)
            self.currentUser = storedUser
            logManager?.trackEvent(event: Event.logInSuccess(user: storedUser))
        }

        addCurrentUserListener(userId: auth.uid)
    }

    /// User Streaming
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

    /// Save current user locally
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
    
    func getUser(userId: String) async throws -> UserModel {
        try await remote.getUser(userId: userId)
    }
    
    // MARK: - Personal Info
    
    func updateUserName(firstName: String? = nil, lastName: String? = nil) async throws {
        let uid = try currentUserId()
        try await remote.saveUserName(userId: uid, firstName: firstName, lastName: lastName)
    }

    func updateUserEmail(email: String) async throws {
        let uid = try currentUserId()
        try await remote.saveUserEmail(userId: uid, email: email)
    }

    // MARK: - Image URL
    
    func updateProfileImage(image: PlatformImage) async throws {
        let uid = try currentUserId()
        try await remote.saveUserProfileImage(userId: uid, image: image)
    }

    func updateGender(gender: Gender) async throws {
        let uid = try currentUserId()
        try await remote.saveUserGender(userId: uid, gender: gender)
    }

    func updateDateOfBirth(dob: Date) async throws {
        let uid = try currentUserId()
        try await remote.saveUserDateOfBirth(userId: uid, dateOfBirth: dob)
    }
    
    func updateUserHeight(heightInCentimeters: Double, lengthUnitPreference: LengthUnitPreference) async throws {
        let uid = try currentUserId()
        try await remote.saveUserHeightCentimeters(userId: uid, heightInCentimeters: heightInCentimeters, lengthUnitPreference: lengthUnitPreference)
    }

    func updateUserWeight(weightInKilograms: Double, weightUnitPreference: WeightUnitPreference) async throws {
        let uid = try currentUserId()
        try await remote.saveUserWeightKilograms(userId: uid, weightInKilograms: weightInKilograms, weightUnitPreference: weightUnitPreference)
    }
    
    func updateUserExerciseFrequency(exerciseFrequency: ExerciseFrequency) async throws {
        let uid = try currentUserId()
        try await remote.saveUserExerciseFrequency(userId: uid, exerciseFrequency: exerciseFrequency)
    }
    
    func updateUserDailyActivityLevel(activityLevel: ActivityLevel) async throws {
        let uid = try currentUserId()
        try await remote.saveUserDailyActivityLevel(userId: uid, activityLevel: activityLevel)
    }

    func updateUserCardioFitnessLevel(cardioFitnessLevel: CardioFitnessLevel) async throws {
        let uid = try currentUserId()
        try await remote.saveUserCardioFitnessLevel(userId: uid, cardioFitnessLevel: cardioFitnessLevel)
    }
    
    func saveUserCompleteAccountSetup(input: CompleteAccountSetupProfileInput) async throws {
        let uid = try currentUserId()
        try await remote.saveUserCompleteAccountSetup(userId: uid, input: input)
    }
        
    // MARK: Update Active Training Program
    
    func updateActiveTrainingProgramId(programId: String?) async throws {
        let uid = try currentUserId()
        guard let activeProgramId = programId else { return }
        try await remote.saveUserActiveTrainingProgramId(userId: uid, activeTrainingProgramId: activeProgramId)
    }

    // MARK: Update Favourite Gym Profile

    func updateFavouriteGymProfileId(profileId: String?) async throws {
        let uid = try currentUserId()
        guard let favouriteGymProfileId = profileId else { return }
        try await remote.saveUserFavouriteGymProfileId(userId: uid, favouriteGymProfileId: favouriteGymProfileId)
    }
    
    func saveOnboardingCompleteForCurrentUser() async throws {
        let uid = try currentUserId()
        try await remote.updateDidCompleteOnboarding(userId: uid)
    }

    // User FCM Token
    
    func saveUserFCMToken(token: String) async throws {
        let uid = try currentUserId()
        try await remote.saveUserFCMToken(userId: uid, token: token)
    }

    // MARK: - Remote operations
    // MARK: - User
    
    func saveUser(user: UserModel) async throws {
        try await remote.saveUser(user: user)
        self.currentUser = user
    }
        
    func signOut() {
        currentUserListenerTask?.cancel()
        currentUserListenerTask = nil
        currentUser = nil
        logManager?.trackEvent(event: Event.signOut)
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
        try await remote.deleteUser(userId: uid)
        logManager?.trackEvent(event: Event.deleteAccountSuccess)

        // Reset UserManager state (does not sign out Auth)
        signOut()
    }
    
    func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
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
    
    var userImageUrl: String? {
        currentUser?.submittedProfileImage
    }
    
    func saveUser(user: UserModel) async throws {
        try await userManager.saveUser(user: user)
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
    
    func updateWeight(userId: String, weight: Double, weightUnitPreference: WeightUnitPreference) async throws {
        try await userManager.updateUserWeight(weightInKilograms: weight, weightUnitPreference: weightUnitPreference)
    }
    
    func saveUserCompleteAccountSetup(input: CompleteAccountSetupProfileInput) async throws {
        try await userManager.saveUserCompleteAccountSetup(input: input)
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
