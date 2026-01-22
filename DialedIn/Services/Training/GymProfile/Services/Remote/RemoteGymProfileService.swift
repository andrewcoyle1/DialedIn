//
//  RemoteGymProfileService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

protocol RemoteGymProfileService {
    // MARK: CREATE
    func createGymProfile(profile: GymProfileModel) async throws
    
    // MARK: READ
    func readGymProfile(profileId: String) async throws -> GymProfileModel
    func readAllGymProfilesForAuthor(userId: String) async throws -> [GymProfileModel]
    
    // MARK: UPDATE
    func updateGymProfile(profile: GymProfileModel) async throws
    
    // MARK: DELETE
    func deleteGymProfile(profile: GymProfileModel) async throws

}
