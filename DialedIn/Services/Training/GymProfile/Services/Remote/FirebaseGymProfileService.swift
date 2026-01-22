//
//  FirebaseGymProfileService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import FirebaseFirestore

struct FirebaseGymProfileService: RemoteGymProfileService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("gym_profiles")
    }
    
    // MARK: CREATE
    func createGymProfile(profile: GymProfileModel) async throws {
        try collection.document(profile.id).setData(from: profile, merge: true)
    }
    
    // MARK: READ
    func readGymProfile(profileId: String) async throws -> GymProfileModel {
        try await collection.getDocument(id: profileId)
    }
    
    func readAllGymProfilesForAuthor(userId: String) async throws -> [GymProfileModel] {
        try await collection
            .whereField(GymProfileModel.CodingKeys.authorId.rawValue, isEqualTo: userId)
            .limit(to: 200)
            .getAllDocuments()
    }
    
    // MARK: UPDATE
    func updateGymProfile(profile: GymProfileModel) async throws {
        try collection.document(profile.id).setData(from: profile)
    }
    
    // MARK: DELETE
    func deleteGymProfile(profile: GymProfileModel) async throws {
        try collection.document(profile.id).setData(from: profile, merge: true)
    }

}
