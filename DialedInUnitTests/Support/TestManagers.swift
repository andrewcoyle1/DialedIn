//
//  TestManagers.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 20/09/2026.
//

import Foundation
@testable import DialedIn

/// Managers built the way `Dependencies` builds them for `.mock`, but with local persistence off.
///
/// Every manager now takes sync engines rather than a services struct, and a sync engine with
/// persistence on opens SwiftData storage keyed by its `managerKey` — shared between tests, and
/// left behind after them. Passing `enableLocalPersistence: false` keeps each test to the data it
/// was given.
@MainActor
enum TestManagers {

    /// A unique key per call, so two engines in the same run never read each other's storage even
    /// if persistence is switched on.
    static func key(_ name: String = "test") -> String {
        "\(name)-\(UUID().uuidString)"
    }

    static func collectionEngine<T: DataSyncModelProtocol>(
        _ collection: [T],
        key name: String = "collection"
    ) -> CollectionSyncEngine<T> {
        CollectionSyncEngine<T>(
            remote: MockRemoteCollectionService(collection: collection),
            managerKey: key(name),
            enableLocalPersistence: false
        )
    }

    static func documentEngine<T: DataSyncModelProtocol>(
        _ document: T?,
        key name: String = "document"
    ) -> DocumentSyncEngine<T> {
        DocumentSyncEngine<T>(
            remote: MockRemoteDocumentService(document: document),
            managerKey: key(name),
            enableLocalPersistence: false
        )
    }

    static func userManager(user: UserModel?, following: [UserModel] = []) -> UserManager {
        UserManager(
            queryService: MockUserQueryService(),
            userSyncEngine: documentEngine(user, key: "user"),
            followingUsersSyncEngine: collectionEngine(following, key: "following-users")
        )
    }

    /// Waits for `condition` to hold, polling until `timeout`. Returns whether it ever did.
    ///
    /// A sync engine applies a write when its listener next emits, which happens on its own task
    /// after the write returns — so `currentCollection` is not up to date the instant `saveDocument`
    /// does. Polling keeps that from being either a fixed sleep or a race.
    @discardableResult
    static func eventually(
        timeout: Duration = .seconds(3),
        _ condition: () -> Bool
    ) async -> Bool {
        let deadline = ContinuousClock.now.advanced(by: timeout)
        while ContinuousClock.now < deadline {
            if condition() { return true }
            try? await Task.sleep(for: .milliseconds(20))
        }
        return condition()
    }

    /// A `UserManager` already listening, so `currentUser` is `user`. Anything reading the signed-in
    /// user's preferences needs this rather than `userManager(user:)`, whose engine holds nothing
    /// until it starts listening.
    static func signedInUserManager(_ user: UserModel?) async throws -> UserManager {
        let manager = userManager(user: user)
        try await manager.signIn(auth: UserAuthInfo(uid: user?.userId ?? "test-user"), isNewUser: false)
        if user != nil {
            await eventually { manager.currentUser != nil }
        }
        return manager
    }

    static func exerciseModelManager(
        user userExercises: [ExerciseModel] = [],
        system systemExercises: [ExerciseModel] = []
    ) -> ExerciseModelManager {
        ExerciseModelManager(
            userExerciseSyncEngine: collectionEngine(userExercises, key: "user-exercises"),
            systemExercisePersistence: MockLocalCollectionPersistence(collection: systemExercises)
        )
    }

    static func gymProfileManager(profiles: [GymProfileModel] = []) -> GymProfileManager {
        GymProfileManager(gymProfileSyncEngine: collectionEngine(profiles, key: "gym-profiles"))
    }

    static func mealLogManager(meals: [MealLogModel] = []) -> MealLogManager {
        MealLogManager(
            draftMealLogPersistence: MockLocalDocumentPersistence<MealLogModel>(),
            mealLogSyncEngine: collectionEngine(meals, key: "meal-logs")
        )
    }

    /// A meal log manager already listening, so `userMeals` holds `meals`.
    static func signedInMealLogManager(meals: [MealLogModel]) async -> MealLogManager {
        let manager = mealLogManager(meals: meals)
        await manager.signIn(userId: "author-1")
        await eventually { manager.userMeals.count == meals.count }
        return manager
    }
}
