//
//  LocalGymProfilePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

protocol LocalGymProfilePersistence {
    
    // MARK: CREATE
    func createGymProfile(profile: GymProfileModel) throws
    
    // MARK: READ
    func readGymProfile(profileId: String) throws -> GymProfileModel
    func readAllLocalGymProfiles(includeDeleted: Bool) throws -> [GymProfileModel]
    
    // MARK: UPDATE
    func updateGymProfile(profile: GymProfileModel) throws
    
    // MARK: DELETE
    func deleteGymProfile(profile: GymProfileModel) throws

}
