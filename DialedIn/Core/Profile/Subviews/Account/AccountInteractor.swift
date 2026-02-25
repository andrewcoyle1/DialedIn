import SwiftUI

@MainActor
protocol AccountInteractor: GlobalInteractor {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    func signOut() async throws
    func deleteUserProfile()
    func deleteAccount() async throws
    func updateProfileImageUrl(image: PlatformImage) async throws
    func saveUser(user: UserModel) async throws
}

extension CoreInteractor: AccountInteractor { }
