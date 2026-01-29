import SwiftUI

@MainActor
protocol GymProfilesInteractor {
    var userId: String? { get }
    var currentUser: UserModel? { get }
    func readAllRemoteGymProfilesForAuthor(userId: String) async throws -> [GymProfileModel]
    func updateFavouriteGymProfileId(profileId: String?) async throws
    func readAllLocalGymProfiles() throws -> [GymProfileModel]
    func deleteGymProfile(profile: GymProfileModel) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: GymProfilesInteractor { }
