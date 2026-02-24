import SwiftUI

@MainActor
protocol GymProfileInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    @discardableResult
    func updateGymProfile(profile: GymProfileModel, image: PlatformImage?) async throws -> GymProfileModel
    func updateFavouriteGymProfileId(profileId: String?) async throws

}

extension CoreInteractor: GymProfileInteractor { }
