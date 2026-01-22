//
//  MockGymProfileService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import Foundation

final class MockGymProfileService: RemoteGymProfileService {
    
    let delay: Double
    let showError: Bool
    private var remoteProfiles: [String: GymProfileModel]
    
    init(delay: Double = 0.0, showError: Bool = false, profiles: [GymProfileModel] = GymProfileModel.mocks) {
        self.delay = delay
        self.showError = showError
        self.remoteProfiles = Dictionary(uniqueKeysWithValues: profiles.map { ($0.id, $0) })
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func createGymProfile(profile: GymProfileModel) async throws {
        try tryShowError()
        remoteProfiles[profile.id] = profile
    }
    
    func readGymProfile(profileId: String) async throws -> GymProfileModel {
        try tryShowError()
        guard let profile = remoteProfiles[profileId] else {
            throw URLError(.fileDoesNotExist)
        }
        return profile
    }
    
    func readAllGymProfilesForAuthor(userId: String) async throws -> [GymProfileModel] {
        try tryShowError()
        return remoteProfiles.values.filter { $0.authorId == userId }
    }
    
    func updateGymProfile(profile: GymProfileModel) async throws {
        try tryShowError()
        remoteProfiles[profile.id] = profile
    }
    
    func deleteGymProfile(profile: GymProfileModel) async throws {
        try tryShowError()
        remoteProfiles[profile.id] = profile
    }

}
