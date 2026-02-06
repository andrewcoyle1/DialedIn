//
//  ProductionRemoteBodyMeasurementService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/16/24.
//

import Foundation
import FirebaseFirestore

struct ProductionRemoteBodyMeasurementService: RemoteBodyMeasurementService {

    private var database: Firestore { Firestore.firestore() }

    private func weightEntriesCollection(userId: String) -> CollectionReference {
        database.collection("users").document(userId).collection("weight_entries")
    }

    // MARK: CREATE
    func createWeightEntry(entry: BodyMeasurementEntry) async throws {
        try weightEntriesCollection(userId: entry.authorId)
            .document(entry.id)
            .setData(from: entry, merge: false)
    }

    // MARK: READ
    func readWeightEntry(userId: String, entryId: String) async throws -> BodyMeasurementEntry {
        try await weightEntriesCollection(userId: userId)
            .getDocument(id: entryId)
    }

    func readAllWeightEntriesForAuthor(userId: String) async throws -> [BodyMeasurementEntry] {
        try await weightEntriesCollection(userId: userId)
            .whereField(DialedIn.BodyMeasurementEntry.CodingKeys.authorId.rawValue, isEqualTo: userId)
            .order(by: "date", descending: true)
            .limit(to: 200)
            .getAllDocuments()
    }

    // MARK: UPDATE
    func updateWeightEntry(entry: BodyMeasurementEntry) async throws {
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
