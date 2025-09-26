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
    
    func logIn(auth: UserAuthInfo, image: PlatformImage? = nil, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        logManager?.trackEvent(event: Event.logInStart(user: user))
        try await remote.saveUser(user: user, image: image)
        logManager?.trackEvent(event: Event.logInSuccess(user: user))
        
        addCurrentUserListener(userId: auth.uid)
    }
    
    func saveUser(user: UserModel, image: PlatformImage?) async throws {
        try await remote.saveUser(user: user, image: image)
    
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
    
    func markOnboardingCompleteForCurrentUser() async throws {
        let uid = try currentUserId()
        try await remote.markOnboardingCompleted(userId: uid)
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
        try await remote.deleteUser(userId: uid)
        self.clearAllLocalData()
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
        
        signOut()
    }
    
    // MARK: - User Streaming
    
    private func addCurrentUserListener(userId: String) {
        currentUserListener?()
        logManager?.trackEvent(event: Event.remoteListenerStart)
        
        Task {
            do {
                for try await value in remote.streamUser(userId: userId, onListenerConfigured: { removal in
                    self.currentUserListener = removal
                }) {
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
