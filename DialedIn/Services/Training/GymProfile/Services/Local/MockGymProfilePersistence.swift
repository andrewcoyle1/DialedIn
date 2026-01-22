//
//  MockGymProfilePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import Foundation

class MockGymProfilePersistence: LocalGymProfilePersistence {
    
    var showError: Bool
    private var profiles: [GymProfileModel]

    init(showError: Bool = false, profiles: [GymProfileModel] = GymProfileModel.mocks) {
        self.showError = showError
        self.profiles = profiles
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func createGymProfile(profile: GymProfileModel) throws {
        try tryShowError()

        profiles.append(profile)
    }
    
    func readGymProfile(profileId: String) throws -> GymProfileModel {
        try tryShowError()

        guard let profile = profiles.first(where: { $0.id == profileId }) else {
            throw URLError(.fileDoesNotExist)
        }
        return profile
    }
    
    func readAllLocalGymProfiles(includeDeleted: Bool) throws -> [GymProfileModel] {
        try tryShowError()
        let filtered = includeDeleted ? profiles : profiles.filter { $0.deletedAt == nil }
        return filtered.sorted { $0.dateCreated > $1.dateCreated }
    }
    
    func updateGymProfile(profile: GymProfileModel) throws {
        try tryShowError()

        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else {
            throw URLError(.fileDoesNotExist)
        }
        profiles[index] = profile
    }
    
    func deleteGymProfile(profile: GymProfileModel) throws {
        try tryShowError()
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else {
            return
        }
        profiles[index].deletedAt = profile.deletedAt ?? .now
        profiles[index].dateModified = profile.dateModified
    }
}
