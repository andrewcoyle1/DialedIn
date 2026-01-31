import SwiftUI

@MainActor
protocol AccountInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func saveUser(user: UserModel, image: PlatformImage?) async throws
}

extension CoreInteractor: AccountInteractor { }
