//
//  ProductionRemoteUserWeightService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation
import FirebaseFirestore

struct ProductionRemoteUserWeightService: RemoteUserWeightService {
    
    private var database: Firestore { Firestore.firestore() }
    
    private func weightEntriesCollection(userId: String) -> CollectionReference {
        database.collection("users").document(userId).collection("weight_entries")
    }

    // MARK: CREATE
    func createWeightEntry(entry: WeightEntry) async throws {
        try weightEntriesCollection(userId: entry.authorId)
            .document(entry.id)
            .setData(from: entry, merge: false)

    }
    
    // MARK: READ
    func readWeightEntry(userId: String, entryId: String) async throws -> WeightEntry {
        try await weightEntriesCollection(userId: userId)
            .getDocument(id: entryId)
    }
    
    func readAllWeightEntriesForAuthor(userId: String) async throws -> [WeightEntry] {
        try await weightEntriesCollection(userId: userId)
            .whereField(DialedIn.WeightEntry.CodingKeys.authorId.rawValue, isEqualTo: userId)
            .order(by: "date", descending: true)
            .limit(to: 200)
            .getAllDocuments()
    }
    
    // MARK: UPDATE
    func updateWeightEntry(entry: WeightEntry) async throws {
        try weightEntriesCollection(userId: entry.authorId)
            .document(entry.id)
            .setData(from: entry, merge: true)
    }
    
    // MARK: DELETE
    func deleteWeightEntry(userId: String, entryId: String) async throws {
        try await weightEntriesCollection(userId: userId)
            .document(entryId)
            .delete()

    }
}
