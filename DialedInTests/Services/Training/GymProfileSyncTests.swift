//
//  GymProfileSyncTests.swift
//  DialedInTests
//
//  Created by AI on 21/01/2026.
//

import Testing
import Foundation

struct GymProfileSyncTests {

    @Test("Remote-only gym profiles are saved locally")
    func testRemoteOnlyProfilesAreSavedLocally() async throws {
        let authorId = "author-1"
        let remoteProfile = makeProfile(
            id: "remote-1",
            authorId: authorId,
            name: "Remote Profile",
            modifiedAt: Date(timeIntervalSince1970: 200)
        )

        let local = MockGymProfilePersistence(profiles: [])
        let remote = InMemoryGymProfileRemoteService(profiles: [remoteProfile])
        let manager = GymProfileManager(services: TestGymProfileServices(local: local, remote: remote))

        let synced = try await manager.readAllRemoteGymProfilesForAuthor(userId: authorId)

        #expect(synced.contains(where: { $0.id == remoteProfile.id }))
        let localProfiles = try local.readAllLocalGymProfiles(includeDeleted: true)
        #expect(localProfiles.count == 1)
        #expect(localProfiles[0].name == remoteProfile.name)
    }

    @Test("Local-only gym profiles are uploaded to remote")
    func testLocalOnlyProfilesAreUploadedToRemote() async throws {
        let authorId = "author-1"
        let localProfile = makeProfile(
            id: "local-1",
            authorId: authorId,
            name: "Local Profile",
            modifiedAt: Date(timeIntervalSince1970: 100)
        )

        let local = MockGymProfilePersistence(profiles: [localProfile])
        let remote = InMemoryGymProfileRemoteService(profiles: [])
        let manager = GymProfileManager(services: TestGymProfileServices(local: local, remote: remote))

        _ = try await manager.readAllRemoteGymProfilesForAuthor(userId: authorId)

        let remoteFetched = try await remote.readGymProfile(profileId: localProfile.id)
        #expect(remoteFetched.name == localProfile.name)
    }

    @Test("Remote newer profile updates local")
    func testRemoteNewerUpdatesLocal() async throws {
        let authorId = "author-1"
        let localProfile = makeProfile(
            id: "sync-1",
            authorId: authorId,
            name: "Local Old",
            modifiedAt: Date(timeIntervalSince1970: 100)
        )
        let remoteProfile = makeProfile(
            id: "sync-1",
            authorId: authorId,
            name: "Remote New",
            modifiedAt: Date(timeIntervalSince1970: 200)
        )

        let local = MockGymProfilePersistence(profiles: [localProfile])
        let remote = InMemoryGymProfileRemoteService(profiles: [remoteProfile])
        let manager = GymProfileManager(services: TestGymProfileServices(local: local, remote: remote))

        _ = try await manager.readAllRemoteGymProfilesForAuthor(userId: authorId)

        let updatedLocal = try local.readGymProfile(profileId: localProfile.id)
        #expect(updatedLocal.name == remoteProfile.name)
    }

    @Test("Local newer profile updates remote")
    func testLocalNewerUpdatesRemote() async throws {
        let authorId = "author-1"
        let localProfile = makeProfile(
            id: "sync-2",
            authorId: authorId,
            name: "Local New",
            modifiedAt: Date(timeIntervalSince1970: 300)
        )
        let remoteProfile = makeProfile(
            id: "sync-2",
            authorId: authorId,
            name: "Remote Old",
            modifiedAt: Date(timeIntervalSince1970: 100)
        )

        let local = MockGymProfilePersistence(profiles: [localProfile])
        let remote = InMemoryGymProfileRemoteService(profiles: [remoteProfile])
        let manager = GymProfileManager(services: TestGymProfileServices(local: local, remote: remote))

        _ = try await manager.readAllRemoteGymProfilesForAuthor(userId: authorId)

        let updatedRemote = try await remote.readGymProfile(profileId: localProfile.id)
        #expect(updatedRemote.name == localProfile.name)
    }

    @Test("Tie on dateModified prefers remote")
    func testTiePrefersRemote() async throws {
        let authorId = "author-1"
        let timestamp = Date(timeIntervalSince1970: 200)
        let localProfile = makeProfile(
            id: "sync-3",
            authorId: authorId,
            name: "Local Name",
            modifiedAt: timestamp
        )
        let remoteProfile = makeProfile(
            id: "sync-3",
            authorId: authorId,
            name: "Remote Name",
            modifiedAt: timestamp
        )

        let local = MockGymProfilePersistence(profiles: [localProfile])
        let remote = InMemoryGymProfileRemoteService(profiles: [remoteProfile])
        let manager = GymProfileManager(services: TestGymProfileServices(local: local, remote: remote))

        _ = try await manager.readAllRemoteGymProfilesForAuthor(userId: authorId)

        let updatedLocal = try local.readGymProfile(profileId: localProfile.id)
        #expect(updatedLocal.name == remoteProfile.name)
    }

    @Test("Remote deletion propagates to local and hides from active list")
    func testRemoteDeletionPropagatesLocally() async throws {
        let authorId = "author-1"
        let timestamp = Date(timeIntervalSince1970: 200)
        let localProfile = makeProfile(
            id: "sync-4",
            authorId: authorId,
            name: "Local Active",
            modifiedAt: Date(timeIntervalSince1970: 100)
        )
        let remoteDeleted = makeProfile(
            id: "sync-4",
            authorId: authorId,
            name: "Remote Deleted",
            modifiedAt: timestamp,
            deletedAt: timestamp
        )

        let local = MockGymProfilePersistence(profiles: [localProfile])
        let remote = InMemoryGymProfileRemoteService(profiles: [remoteDeleted])
        let manager = GymProfileManager(services: TestGymProfileServices(local: local, remote: remote))

        let active = try await manager.readAllRemoteGymProfilesForAuthor(userId: authorId)

        #expect(active.isEmpty)
        let stored = try local.readAllLocalGymProfiles(includeDeleted: true)
        #expect(stored.first?.deletedAt != nil)
    }

    @Test("Local deletion uploads tombstone to remote")
    func testLocalDeletionUploadsTombstone() async throws {
        let authorId = "author-1"
        let timestamp = Date(timeIntervalSince1970: 200)
        let localDeleted = makeProfile(
            id: "sync-5",
            authorId: authorId,
            name: "Local Deleted",
            modifiedAt: timestamp,
            deletedAt: timestamp
        )

        let local = MockGymProfilePersistence(profiles: [localDeleted])
        let remote = InMemoryGymProfileRemoteService(profiles: [])
        let manager = GymProfileManager(services: TestGymProfileServices(local: local, remote: remote))

        _ = try await manager.readAllRemoteGymProfilesForAuthor(userId: authorId)

        let remoteFetched = try await remote.readGymProfile(profileId: localDeleted.id)
        #expect(remoteFetched.deletedAt != nil)
    }
}

private func makeProfile(
    id: String,
    authorId: String,
    name: String,
    modifiedAt: Date,
    deletedAt: Date? = nil
) -> GymProfileModel {
    GymProfileModel(
        id: id,
        authorId: authorId,
        name: name,
        dateCreated: modifiedAt,
        dateModified: modifiedAt,
        deletedAt: deletedAt
    )
}

private struct TestGymProfileServices: GymProfileServices {
    let local: LocalGymProfilePersistence
    let remote: RemoteGymProfileService
}

private final class InMemoryGymProfileRemoteService: RemoteGymProfileService {
    private var profiles: [String: GymProfileModel]

    init(profiles: [GymProfileModel]) {
        self.profiles = Dictionary(uniqueKeysWithValues: profiles.map { ($0.id, $0) })
    }

    func createGymProfile(profile: GymProfileModel) async throws {
        profiles[profile.id] = profile
    }

    func readGymProfile(profileId: String) async throws -> GymProfileModel {
        guard let profile = profiles[profileId] else {
            throw URLError(.fileDoesNotExist)
        }
        return profile
    }

    func readAllGymProfilesForAuthor(userId: String) async throws -> [GymProfileModel] {
        profiles.values.filter { $0.authorId == userId }
    }

    func updateGymProfile(profile: GymProfileModel) async throws {
        profiles[profile.id] = profile
    }

    func deleteGymProfile(profile: GymProfileModel) async throws {
        profiles[profile.id] = profile
    }
}
