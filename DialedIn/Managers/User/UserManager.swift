//
//  UserManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/14/24.
//

import SwiftUI
import SwiftfulAuthenticating

@Observable
@MainActor
class UserManager {

    private let queryService: any UserQueryService
    private let userSyncEngine: DocumentSyncEngine<UserModel>
    private let followingUsersSyncEngine: CollectionSyncEngine<UserModel>
    private let privateSettingsSyncEngine: DocumentSyncEngine<PrivateUserSettings>

    var currentUser: UserModel? { userSyncEngine.currentDocument }

    /// The owner-only settings document. A user who has never written it reads as all defaults.
    var privateSettings: PrivateUserSettings { privateSettingsSyncEngine.currentDocument ?? PrivateUserSettings() }

    /// Blocked accounts are left out even while their follow is still being taken back.
    var followingUsers: [UserModel] {
        followingUsersSyncEngine.currentCollection.filter { !isBlocked($0) }
    }

    private func isBlocked(_ user: UserModel) -> Bool {
        currentUser?.hasBlocked(user.userId) ?? false
    }

    init(
        queryService: any UserQueryService,
        userSyncEngine: DocumentSyncEngine<UserModel>,
        followingUsersSyncEngine: CollectionSyncEngine<UserModel>,
        privateSettingsSyncEngine: DocumentSyncEngine<PrivateUserSettings>
    ) {
        self.queryService = queryService
        self.userSyncEngine = userSyncEngine
        self.followingUsersSyncEngine = followingUsersSyncEngine
        self.privateSettingsSyncEngine = privateSettingsSyncEngine
    }
    
    func signIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        if isNewUser {
            // New user: create their Firestore document from auth data.
            let user = UserModel(auth: auth, creationVersion: Utilities.appVersion)
            try await userSyncEngine.saveDocument(user)
        }
        try await userSyncEngine.startListening(documentId: auth.uid)
        try await privateSettingsSyncEngine.startListening(documentId: PrivateUserSettings.documentId)
    }
    
    func signOut() {
        userSyncEngine.stopListening()
        followingUsersSyncEngine.stopListening()
        privateSettingsSyncEngine.stopListening()
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
    
    /// Unit preferences on their own. The height and weight updates above each write a measurement
    /// alongside its unit, which the settings screen has no business changing.
    func updateUnitPreferences(
        length: LengthUnitPreference,
        weight: WeightUnitPreference,
        distance: DistanceUnitPreference
    ) async throws {
        try await userSyncEngine.updateDocument(
            data: [
                UserModel.CodingKeys.submittedLengthUnitPreference.rawValue: length.rawValue,
                UserModel.CodingKeys.submittedWeightUnitPreference.rawValue: weight.rawValue,
                UserModel.CodingKeys.submittedDistanceUnitPreference.rawValue: distance.rawValue
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
    
    /// Written to the owner-only private document, merged over what is there. `saveDocument` is a
    /// merge, so this cannot fail on a document that does not exist yet the way an update would.
    func saveUserFCMToken(token: String) async throws {
        var settings = privateSettings
        settings.fcmToken = token
        try await privateSettingsSyncEngine.saveDocument(settings)
        // ponytail: legacy public copy for the Cloud Function deployed before the private doc.
        // Drop this write one release after the functions deploy that reads users/{uid}/private/settings.
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
        try await queryService.fetchFollowers(userId: userId).filter { !isBlocked($0) }
    }

    // MARK: - User Search

    func searchUsers(query: String) async throws -> [UserModel] {
        try await queryService.searchUsers(query: query).filter { !isBlocked($0) }
    }

    /// People worth following when the reader follows nobody: the newest accounts, minus the
    /// reader, anyone they already follow, and anyone they have blocked.
    func fetchSuggestedUsers(limit: Int = 10) async throws -> [UserModel] {
        let excluded = Set(
            [currentUser?.userId].compactMap { $0 }
            + (currentUser?.followingIds ?? [])
            + (currentUser?.blockedUserIds ?? [])
        )
        // Over-fetch so the exclusions do not leave the list short.
        return try await queryService.fetchSuggestedUsers(limit: limit + excluded.count)
            .filter { !excluded.contains($0.userId) && $0.isPrivate != true }
            .prefix(limit)
            .map { $0 }
    }

    func updatePrivacy(isPrivate: Bool) async throws {
        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.isPrivate.rawValue: isPrivate
        ])
    }

    func updateSocialNotificationPreferences(type: ActivityNotificationModel.ActivityType, isEnabled: Bool) async throws {
        try await privateSettingsSyncEngine.saveDocument(privateSettings.settingSocialPush(type, isEnabled: isEnabled))
    }

    // MARK: - User Blocking

    /// Blocking also takes back the reader's follow, in the same write, so there is no moment where
    /// the block has landed and the follow has not.
    func blockUser(userId: String) async throws {
        var blockList = currentUser?.blockedUserIds ?? []
        if !blockList.contains(userId) {
            blockList.append(userId)
        }
        let followingIds = (currentUser?.followingIds ?? []).filter { $0 != userId }

        try await userSyncEngine.updateDocument(data: [
            UserModel.CodingKeys.blockedUserIds.rawValue: blockList,
            UserModel.CodingKeys.followingIds.rawValue: followingIds
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
        // Best effort: most users never wrote the private document, and deleting nothing is not a failure.
        try? await privateSettingsSyncEngine.deleteDocument()
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

    func updateUnitPreferences(
        length: LengthUnitPreference,
        weight: WeightUnitPreference,
        distance: DistanceUnitPreference
    ) async throws {
        try await userManager.updateUnitPreferences(length: length, weight: weight, distance: distance)
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
        let wasFollowing = currentUser?.followingIds?.contains(userId) ?? false
        try await userManager.blockUser(userId: userId)
        if wasFollowing {
            await didUnfollow(userId: userId)
        }
    }

    func unblockUser(userId: String) async throws {
        try await userManager.unblockUser(userId: userId)
    }

    // User Following

    var followingUsers: [UserModel] {
        userManager.followingUsers
    }

    func getUser(userId: String) async throws -> UserModel {
        try await userManager.getUser(userId: userId)
    }

    func followUser(userId: String) async throws {
        try await userManager.followUser(userId: userId)
        let ids = userManager.currentUser?.followingIds ?? []
        async let refreshSessions: () = workoutSessionManager.refreshFollowingSync(followingIds: ids)
        async let refreshProfiles: () = userManager.refreshFollowingUsers(followingIds: ids)
        await refreshSessions
        await refreshProfiles
        // The followed user hears about it the same way they hear about a like: a notification in
        // their own collection, keyed so that an unfollow can take it back.
        guard let actor = userManager.currentUser else { return }
        let notification = ActivityNotificationModel(
            id: "follow_\(actor.userId)",
            type: .follow,
            actorId: actor.userId,
            actorName: actor.fullNameCalculated ?? "Someone",
            actorImageUrl: actor.submittedProfileImage,
            sessionId: "",
            sessionAuthorId: userId,
            commentText: nil,
            dateCreated: .now,
            isRead: false
        )
        try? await activityNotificationManager.addNotification(notification, userId: userId)
    }

    func unfollowUser(userId: String) async throws {
        try await userManager.unfollowUser(userId: userId)
        await didUnfollow(userId: userId)
    }

    /// Stops syncing an unfollowed user's sessions and profile, and takes back the follow
    /// notification. `userId` is removed explicitly because the engine may not have applied the
    /// write yet.
    private func didUnfollow(userId: String) async {
        let ids = (userManager.currentUser?.followingIds ?? []).filter { $0 != userId }
        async let refreshSessions: () = workoutSessionManager.refreshFollowingSync(followingIds: ids)
        async let refreshProfiles: () = userManager.refreshFollowingUsers(followingIds: ids)
        await refreshSessions
        await refreshProfiles
        guard let actorId = userManager.currentUser?.userId else { return }
        try? await activityNotificationManager.deleteNotification(id: "follow_\(actorId)", userId: userId)
    }

    func fetchFollowers(userId: String) async throws -> [UserModel] {
        try await userManager.fetchFollowers(userId: userId)
    }

    func fetchSuggestedUsers() async throws -> [UserModel] {
        try await userManager.fetchSuggestedUsers()
    }

    func updatePrivacy(isPrivate: Bool) async throws {
        try await userManager.updatePrivacy(isPrivate: isPrivate)
    }

    var privateUserSettings: PrivateUserSettings {
        userManager.privateSettings
    }

    func updateSocialNotificationPreferences(type: ActivityNotificationModel.ActivityType, isEnabled: Bool) async throws {
        try await userManager.updateSocialNotificationPreferences(type: type, isEnabled: isEnabled)
    }

}
