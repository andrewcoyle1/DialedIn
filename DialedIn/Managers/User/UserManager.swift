//
//  UserManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/14/24.
//

import SwiftUI
import SwiftfulAuthenticating
@preconcurrency import FirebaseFirestore

@Observable
@MainActor
class UserManager {
    
    private let userSyncEngine: DocumentSyncEngine<UserModel>
    private let followingUsersSyncEngine: CollectionSyncEngine<UserModel>

    var currentUser: UserModel? { userSyncEngine.currentDocument }

    var followingUsers: [UserModel] {
        followingUsersSyncEngine.currentCollection
    }

    init(
        userSyncEngine: DocumentSyncEngine<UserModel>,
        followingUsersSyncEngine: CollectionSyncEngine<UserModel>
    ) {
        self.userSyncEngine = userSyncEngine
        self.followingUsersSyncEngine = followingUsersSyncEngine
    }
    
    func signIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        if isNewUser {
            // New user: create their Firestore document from auth data.
            let user = UserModel(auth: auth, creationVersion: Utilities.appVersion)
            try await userSyncEngine.saveDocument(user)
        }
        try await userSyncEngine.startListening(documentId: auth.uid)
    }

//    func signIn(userId: String) async throws {
//
//        try await userSyncEngine.startListening(documentId: userId)
//    }
    
    func signOut() {
        userSyncEngine.stopListening()
        followingUsersSyncEngine.stopListening()
    }

    func refreshFollowingUsers(followingIds: [String]) async {
        guard !followingIds.isEmpty else {
            followingUsersSyncEngine.stopListening()
            return
        }
        await followingUsersSyncEngine.startListening { query in
            query.where("user_id", in: followingIds)
        }
    }
    
//    /// Log In
//    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
//        if isNewUser {
//            // New user: create their Firestore document from auth data.
//            let user = UserModel(auth: auth, creationVersion: Utilities.appVersion)
//            logManager?.trackEvent(event: Event.logInStart(user: user))
//            try await remote.saveUser(user: user)
//            logManager?.trackEvent(event: Event.logInSuccess(user: user))
//        } else {
//            // Returning user: fetch their existing document so currentUser is correct
//            // before any routing decisions are made. Writing an auth-only stub would
//            // overwrite non-optional fields like didCompleteOnboarding with defaults.
//            logManager?.trackEvent(event: Event.logInStart(user: currentUser))
//            let storedUser = try await remote.getUser(userId: auth.uid)
//            logManager?.trackEvent(event: Event.logInSuccess(user: storedUser))
//        }
//
//        addCurrentUserListener(userId: auth.uid)
//    }

    // MARK: - Personal Info
    
    func updateUser(data: [String: any DMCodableSendable]) async throws {
        try await userSyncEngine.updateDocument(data: data)
    }
    
    func updateUserName(firstName: String? = nil, lastName: String? = nil) async throws {
        var data: [String: any DMCodableSendable] = [:]
        if let firstName = firstName {
            data["submitted_first_name"] = firstName
        }
        if let lastName = lastName {
            data["submitted_last_name"] = lastName
        }
        try await userSyncEngine.updateDocument(data: data)
    }

    func updateUserEmail(email: String) async throws {
        try await userSyncEngine.updateDocument(data: ["submitted_email": email])
    }

    // MARK: - Image URL
    
    func updateProfileImage(image: PlatformImage) async throws {
        guard let userId = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        
        let path = "users/\(userId)/profile"
        let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)

        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.submittedProfileImage.rawValue: url.absoluteString
        ])
    }

    func updateGender(gender: Gender) async throws {
        try await userSyncEngine.updateDocument(data: [UserModel.CodingKeys.submittedGender.rawValue: gender.rawValue])
    }

    func updateDateOfBirth(dob: Date) async throws {
        try await userSyncEngine.updateDocument(data: [UserModel.CodingKeys.submittedDateOfBirth.rawValue: dob])
    }
    
    func updateUserHeight(heightInCentimeters: Double, lengthUnitPreference: LengthUnitPreference) async throws {
        try await userSyncEngine.updateDocument(
            data: [
                UserModel.CodingKeys.submittedHeightCentimeters.rawValue: heightInCentimeters,
                UserModel.CodingKeys.submittedLengthUnitPreference.rawValue: lengthUnitPreference.rawValue
            ]
        )
    }

    func updateUserWeight(weightInKilograms: Double, weightUnitPreference: WeightUnitPreference) async throws {
        try await userSyncEngine.updateDocument(
            data: [
                UserModel.CodingKeys.submittedWeightKilograms.rawValue: weightInKilograms,
                UserModel.CodingKeys.submittedWeightUnitPreference.rawValue: weightUnitPreference.rawValue
            ]
        )
    }
    
    func updateUserExerciseFrequency(exerciseFrequency: ExerciseFrequency) async throws {
        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.submittedExerciseFrequency.rawValue: exerciseFrequency.rawValue
        ])
    }
    
    func updateUserDailyActivityLevel(activityLevel: ActivityLevel) async throws {
        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.submittedDailyActivityLevel.rawValue: activityLevel.rawValue
        ])
    }

    func updateUserCardioFitnessLevel(cardioFitnessLevel: CardioFitnessLevel) async throws {
        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.submittedCardioFitnessLevel.rawValue: cardioFitnessLevel.rawValue
        ])
    }
    
    func saveUserCompleteAccountSetup(input data: [String: any DMCodableSendable]) async throws {
        try await userSyncEngine.updateDocument(data: data)
    }
        
    // MARK: Update Active Training Program
    
    func updateActiveTrainingProgramId(programId: String?) async throws {
        guard let activeProgramId = programId else { return }
        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.submittedActiveTrainingProgramId.rawValue: activeProgramId
        ])
    }

    // MARK: Update Favourite Gym Profile

    func updateFavouriteGymProfileId(profileId: String?) async throws {
        guard let favouriteGymProfileId = profileId else { return }
        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.submittedFavouriteGymProfileId.rawValue: favouriteGymProfileId
        ])
    }
    
    func saveOnboardingCompleteForCurrentUser() async throws {
        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true
        ])
    }

    // User FCM Token
    
    func saveUserFCMToken(token: String) async throws {
        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.fcmToken.rawValue: token
        ])
    }

    // MARK: - Goal Settings
    func updateCurrentGoalId(goalId: String?) async throws {
        guard let currentGoalId = goalId else { return }
        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.submittedCurrentGoalId.rawValue: currentGoalId
        ])
    }
    
    // MARK: - Consents
    func updateHealthConsents(disclaimerVersion: String, privacyVersion: String, acceptedAt: Date = Date()) async throws {
        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.acceptedHealthDisclaimerVersion.rawValue: disclaimerVersion,
            UserModel.CodingKeys.acceptedHealthDisclaimerDate.rawValue: acceptedAt,
            UserModel.CodingKeys.acceptedHealthPrivacyPolicyVersion.rawValue: privacyVersion,
            UserModel.CodingKeys.acceptedHealthPrivacyPolicyDate.rawValue: acceptedAt
        ])
    }
    
    // MARK: - User Lookup

    func getUser(userId: String) async throws -> UserModel {
        try await userSyncEngine.getDocumentAsync(id: userId)
    }

    // MARK: - User Followers

    func fetchFollowers(userId: String) async throws -> [UserModel] {
        try await Firestore.firestore()
            .collection("users")
            .whereField(UserModel.CodingKeys.followingIds.rawValue, arrayContains: userId)
            .limit(to: 200)
            .getAllDocuments()
    }

    // MARK: - User Search

    func searchUsers(query: String) async throws -> [UserModel] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let capitalizedQuery = trimmed.prefix(1).uppercased() + trimmed.dropFirst()
        let field = UserModel.CodingKeys.submittedFirstName.rawValue

        return try await Firestore.firestore()
            .collection("users")
            .whereField(field, isGreaterThanOrEqualTo: capitalizedQuery)
            .whereField(field, isLessThan: capitalizedQuery + "\u{f8ff}")
            .limit(to: 20)
            .getAllDocuments()
    }

    // MARK: - User Blocking

    func blockUser(userId: String) async throws {
        var blockList = currentUser?.blockedUserIds ?? []
        if !blockList.contains(userId) {
            blockList.append(userId)
        }
        
        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.blockedUserIds.rawValue: blockList
        ])
    }
    
    func unblockUser(userId: String) async throws {
        var blockedUserIds = currentUser?.blockedUserIds ?? []
        if let index = blockedUserIds.firstIndex(of: userId) {
            blockedUserIds.remove(at: index)
        }

        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.blockedUserIds.rawValue: blockedUserIds
        ])
    }

    // MARK: - User Following

    func followUser(userId: String) async throws {
        var followingIds = currentUser?.followingIds ?? []
        if !followingIds.contains(userId) {
            followingIds.append(userId)
        }

        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.followingIds.rawValue: followingIds
        ])
    }

    func unfollowUser(userId: String) async throws {
        var followingIds = currentUser?.followingIds ?? []
        if let index = followingIds.firstIndex(of: userId) {
            followingIds.remove(at: index)
        }

        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.followingIds.rawValue: followingIds
        ])
    }
    
    // MARK: - User deletion
    
    /// Deletes the user profile document and clears local state.
    /// Note: This method only handles user profile deletion. The caller (typically CoreInteractor)
    /// is responsible for orchestrating deletion of related data (workout sessions, exercise history, templates, etc.)
    func deleteCurrentUser() async throws {
        try await userSyncEngine.deleteDocument()
        // Reset UserManager state (does not sign out Auth)
        signOut()
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
        try await trainingProgramManager.setActiveProgram(programId: programId)
    }

    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    var userId: String? {
        userManager.currentUser?.userId
    }
        
    var userImageUrl: String? {
        currentUser?.submittedProfileImage
    }
              
    func updateUser(data: [String: any DMCodableSendable]) async throws {
        try await userManager.updateUser(data: data)
    }

    func updateUserName(firstName: String? = nil, lastName: String? = nil) async throws {
        try await userManager.updateUserName(firstName: firstName, lastName: lastName)
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
    
    func saveUserCompleteAccountSetup(input: [String: any DMCodableSendable]) async throws {
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

    // User Following

    var followingUsers: [UserModel] {
        userManager.followingUsers
    }

    func followUser(userId: String) async throws {
        try await userManager.followUser(userId: userId)
        let ids = userManager.currentUser?.followingIds ?? []
        async let refreshSessions: () = workoutSessionManager.refreshFollowingSync(followingIds: ids)
        async let refreshProfiles: () = userManager.refreshFollowingUsers(followingIds: ids)
        await refreshSessions
        await refreshProfiles
    }

    func unfollowUser(userId: String) async throws {
        try await userManager.unfollowUser(userId: userId)
        let ids = userManager.currentUser?.followingIds ?? []
        async let refreshSessions: () = workoutSessionManager.refreshFollowingSync(followingIds: ids)
        async let refreshProfiles: () = userManager.refreshFollowingUsers(followingIds: ids)
        await refreshSessions
        await refreshProfiles
    }

    func fetchFollowers(userId: String) async throws -> [UserModel] {
        try await userManager.fetchFollowers(userId: userId)
    }

}
