//
//  ProductionRemoteUserWeightService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation
import FirebaseFirestore
import SwiftfulFirestore

struct ProductionRemoteUserWeightService: RemoteUserWeightService {
    
    private var database: Firestore { Firestore.firestore() }
    
    private func weightEntriesCollection(userId: String) -> CollectionReference {
        database.collection("users").document(userId).collection("weight_entries")
    }
    
    func saveWeightEntry(_ entry: WeightEntry) async throws {
        try weightEntriesCollection(userId: entry.userId)
            .document(entry.id)
            .setData(from: entry, merge: false)
    }
    
    func getWeightHistory(userId: String, limit: Int?) async throws -> [WeightEntry] {
        var query: Query = weightEntriesCollection(userId: userId)
            .order(by: "date", descending: true)
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let snapshot = try await query.getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: WeightEntry.self) }
    }
    
    func deleteWeightEntry(id: String, userId: String) async throws {
        try await weightEntriesCollection(userId: userId).document(id).delete()
    }
}
