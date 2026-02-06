import SwiftUI

@MainActor
protocol AccountInteractor: GlobalInteractor {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    func signOut() async throws
    func deleteCurrentUser() async throws
    func deleteUserProfile()
    func deleteAccount() async throws
    func saveUser(user: UserModel, image: PlatformImage?) async throws
    func reauthenticateApple() async throws
    func updateAppState(showTabBarView: Bool)
}

extension CoreInteractor: AccountInteractor { }
