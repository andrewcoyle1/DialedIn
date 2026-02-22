//
//  FirebaseStepsModelSercice.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import FirebaseFirestore

struct FirebaseStepsService: RemoteStepsService {
    
    private var database: Firestore { Firestore.firestore() }

    private func stepEntriesCollection(userId: String) -> CollectionReference {
        database.collection("users").document(userId).collection("steps")
    }

    // MARK: CREATE
    func createStepsEntry(steps: StepsModel) async throws {
        try stepEntriesCollection(userId: steps.authorId)
            .document(steps.id)
            .setData(from: steps, merge: true)
    }
    
    // MARK: READ
    func readStepsEntry(userId: String, stepsId: String) async throws -> StepsModel {
        try await stepEntriesCollection(userId: userId)
            .getDocument(id: stepsId)
    }
    
    func readAllStepsEntriesForAuthor(userId: String) async throws -> [StepsModel] {
        try await stepEntriesCollection(userId: userId)
            .limit(to: 200)
            .getAllDocuments()
    }
    
    // MARK: UPDATE
    func updateStepsEntry(steps: StepsModel) async throws {
        try stepEntriesCollection(userId: steps.authorId)
            .document(steps.id).setData(from: steps)
    }
    
    // MARK: DELETE
    func deleteStepsEntry(userId: String, stepsId: String) async throws {
        try await stepEntriesCollection(userId: userId)
            .document(stepsId).delete()
    }

    func deleteAllStepsEntriesForUser(userId: String) async throws {
        let entries = try await readAllStepsEntriesForAuthor(userId: userId)
        try await withThrowingTaskGroup(of: Void.self) { group in
            for entry in entries {
                group.addTask {
                    try await deleteStepsEntry(userId: userId, stepsId: entry.id)
                }
            }
            try await group.waitForAll()
        }
    }
}
