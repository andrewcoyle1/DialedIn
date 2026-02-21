//
//  Firestore+EXT.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

@preconcurrency import FirebaseFirestore

//// MARK: - CollectionReference Extensions
//
//extension CollectionReference {
//    
//    /// Fetches a single document by ID and decodes it to the specified type
//    func getDocument<T: Decodable>(id: String) async throws -> T {
//        let snapshot = try await self.document(id).getDocument()
//        
//        guard snapshot.exists else {
//            throw NSError(
//                domain: "FirestoreExtension",
//                code: 404,
//                userInfo: [NSLocalizedDescriptionKey: "Document not found"]
//            )
//        }
//        
//        return try snapshot.data(as: T.self)
//    }
//    
//    /// Fetches multiple documents by IDs and decodes them to the specified type
//    func getDocuments<T: Decodable>(ids: [String]) async throws -> [T] {
//        guard !ids.isEmpty else { return [] }
//        
//        var results: [T] = []
//        
//        // Firestore 'in' queries are limited to 10 items at a time
//        let batchSize = 10
//        for batchStart in stride(from: 0, to: ids.count, by: batchSize) {
//            let batchEnd = min(batchStart + batchSize, ids.count)
//            let batchIds = Array(ids[batchStart..<batchEnd])
//            
//            let snapshot = try await self
//                .whereField(FieldPath.documentID(), in: batchIds)
//                .getDocuments()
//            
//            let batchResults: [T] = snapshot.documents.compactMap { doc in
//                try? doc.data(as: T.self)
//            }
//            
//            results.append(contentsOf: batchResults)
//        }
//        
//        return results
//    }
//}

// MARK: - Query Extensions

extension Query {
    
    /// Fetches all documents from a query and decodes them to the specified type
    func getAllDocuments<T: Decodable>() async throws -> [T] {
        let snapshot = try await self.getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: T.self)
        }
    }
}
