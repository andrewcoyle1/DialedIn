//
//  GymProfileManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import Foundation

@Observable
class GymProfileManager {
    
    private let local: LocalGymProfilePersistence
    private let remote: RemoteGymProfileService
    
    private(set) var defaultGymProfile: GymProfileModel?
    
    private(set) var gymProfiles: [GymProfileModel] = []
    
    init(services: GymProfileServices) {
        self.local = services.local
        self.remote = services.remote
    }
    
    // MARK: CREATE
    func createGymProfile(profile: GymProfileModel) async throws {
        try local.createGymProfile(profile: profile)
        try await remote.createGymProfile(profile: profile)
    }

    // MARK: READ
    
    func readLocalGymProfile(profileId: String) throws -> GymProfileModel {
        try local.readGymProfile(profileId: profileId)
    }
    
    func readAllLocalGymProfiles() throws -> [GymProfileModel] {
        try local.readAllLocalGymProfiles(includeDeleted: false)
    }
    
    func readRemoteGymProfile(profileId: String) async throws -> GymProfileModel {
        try await remote.readGymProfile(profileId: profileId)
    }
    
    func readAllRemoteGymProfilesForAuthor(userId: String) async throws -> [GymProfileModel] {
        let remoteProfiles = try await remote.readAllGymProfilesForAuthor(userId: userId)
        let localProfiles = try local.readAllLocalGymProfiles(includeDeleted: true)

        let remoteById = Dictionary(uniqueKeysWithValues: remoteProfiles.map { ($0.id, $0) })
        let localById = Dictionary(uniqueKeysWithValues: localProfiles.map { ($0.id, $0) })

        let allIds = Set(remoteById.keys).union(localById.keys)

        func upsertLocal(profile: GymProfileModel) throws {
            do {
                try local.createGymProfile(profile: profile)
            } catch {
                try local.updateGymProfile(profile: profile)
            }
        }

        for id in allIds {
            switch (remoteById[id], localById[id]) {
            case let (remoteProfile?, nil):
                try upsertLocal(profile: remoteProfile)
            case let (nil, localProfile?):
                try await remote.updateGymProfile(profile: localProfile)
            case let (remoteProfile?, localProfile?):
                if remoteProfile.dateModified > localProfile.dateModified {
                    try local.updateGymProfile(profile: remoteProfile)
                } else if localProfile.dateModified > remoteProfile.dateModified {
                    try await remote.updateGymProfile(profile: localProfile)
                } else {
                    try local.updateGymProfile(profile: remoteProfile)
                }
            case (nil, nil):
                break
            }
        }

        return try local.readAllLocalGymProfiles(includeDeleted: false)
    }

    // MARK: UPDATE
    
    @discardableResult
    func updateGymProfile(profile: GymProfileModel, image: PlatformImage? = nil) async throws -> GymProfileModel {
        
        if let image {
            var profileToSave = profile
            // Upload the image
            let path = "gym_profiles/\(profile.id)/image.jpg"
            let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
            
            // Persist the download URL on the ingredient that will be saved
            profileToSave.updateImageUrl(imageUrl: url.absoluteString)
            do {
                try local.updateGymProfile(profile: profileToSave)
            } catch let error as URLError where error.code == .fileDoesNotExist {
                try local.createGymProfile(profile: profileToSave)
            }

            try await remote.updateGymProfile(profile: profileToSave)
            return profileToSave
        } else {
            
            do {
                try local.updateGymProfile(profile: profile)
            } catch let error as URLError where error.code == .fileDoesNotExist {
                try local.createGymProfile(profile: profile)
            }
            try await remote.updateGymProfile(profile: profile)
            return profile
        }
    }

    // MARK: DELETE
        
    func deleteGymProfile(profile: GymProfileModel) async throws {
        var deletedProfile = profile
        deletedProfile.deletedAt = .now
        deletedProfile.dateModified = .now
        try local.deleteGymProfile(profile: deletedProfile)
        try await remote.deleteGymProfile(profile: deletedProfile)
    }

}
