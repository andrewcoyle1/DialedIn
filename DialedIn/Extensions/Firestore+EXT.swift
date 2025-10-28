//
//  Firestore+EXT.swift
//  DialedIn
//
//  Created by Cursor on 28/10/2025.
//

@preconcurrency import FirebaseFirestore

// MARK: - CollectionReference Extensions

extension CollectionReference {
    
    /// Fetches a single document by ID and decodes it to the specified type
    func getDocument<T: Decodable>(id: String) async throws -> T {
        let snapshot = try await self.document(id).getDocument()
        
        guard snapshot.exists else {
            throw NSError(
                domain: "FirestoreExtension",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Document not found"]
            )
        }
        
        return try snapshot.data(as: T.self)
    }
    
    /// Fetches multiple documents by IDs and decodes them to the specified type
    func getDocuments<T: Decodable>(ids: [String]) async throws -> [T] {
        guard !ids.isEmpty else { return [] }
        
        var results: [T] = []
        
        // Firestore 'in' queries are limited to 10 items at a time
        let batchSize = 10
        for batchStart in stride(from: 0, to: ids.count, by: batchSize) {
            let batchEnd = min(batchStart + batchSize, ids.count)
            let batchIds = Array(ids[batchStart..<batchEnd])
            
            let snapshot = try await self
                .whereField(FieldPath.documentID(), in: batchIds)
                .getDocuments()
            
            let batchResults: [T] = snapshot.documents.compactMap { doc in
                try? doc.data(as: T.self)
            }
            
            results.append(contentsOf: batchResults)
        }
        
        return results
    }
    
    /// Streams a document by ID and emits decoded values
    func streamDocument<T: Decodable & Sendable>(id: String) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream { continuation in
            let listener = self.document(id).addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let snapshot = snapshot, snapshot.exists else {
                    continuation.finish(throwing: NSError(
                        domain: "FirestoreExtension",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Document not found"]
                    ))
                    return
                }
                
                do {
                    let value = try snapshot.data(as: T.self)
                    continuation.yield(value)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
}

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
