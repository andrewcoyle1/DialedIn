//
//  FirebaseWorkoutSessionServiceWithSubcollections.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/09/2025.
//

import FirebaseFirestore
import SwiftfulFirestore

/// Enhanced Firebase service that stores workout sessions with sets as subcollections
/// This provides better scalability and query performance for large workout sessions
struct FirebaseWorkoutSessionService: RemoteWorkoutSessionService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("workout_sessions")
    }
    
    // MARK: - Create Operations
    
    /// Creates a workout session with sets stored as subcollections
    func createWorkoutSession(session: WorkoutSessionModel) async throws {
        let database = Firestore.firestore()
        let batch = database.batch()
        
        // Create session document without exercises.sets (we'll store those in subcollections)
        let sessionDoc = collection.document(session.id)
        let sessionData = try Firestore.Encoder().encode(session.forFirebaseStorage())
        batch.setData(sessionData, forDocument: sessionDoc, merge: true)
        
        // Create exercises subcollection with their sets as further subcollections
        for exercise in session.exercises {
            let exerciseDoc = sessionDoc.collection("exercises").document(exercise.id)
            let exerciseData = try Firestore.Encoder().encode(exercise.forFirebaseStorage())
            batch.setData(exerciseData, forDocument: exerciseDoc, merge: true)
            
            // Create sets subcollection for each exercise
            for set in exercise.sets {
                let setDoc = exerciseDoc.collection("sets").document(set.id)
                let setData = try Firestore.Encoder().encode(set)
                batch.setData(setData, forDocument: setDoc, merge: true)
            }
        }
        
        try await batch.commit()
    }
    
    // MARK: - Read Operations
    
    /// Retrieves a complete workout session including all exercises and sets
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel {
        let sessionDoc = collection.document(id)
        
        // Get session data
        let sessionSnapshot = try await sessionDoc.getDocument()
        guard let sessionData = sessionSnapshot.data() else {
            throw NSError(domain: "FirebaseWorkoutSessionService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Workout session not found"])
        }
        
        let session = try Firestore.Decoder().decode(WorkoutSessionModel.self, from: sessionData)
        
        // Get exercises with their sets
        let exercisesSnapshot = try await sessionDoc.collection("exercises").order(by: "index").getDocuments()
        var exercises: [WorkoutExerciseModel] = []
        
        for exerciseDoc in exercisesSnapshot.documents {
            var exercise = try Firestore.Decoder().decode(WorkoutExerciseModel.self, from: exerciseDoc.data())
            
            // Get sets for this exercise
            let setsSnapshot = try await exerciseDoc.reference.collection("sets").order(by: "index").getDocuments()
            let sets = try setsSnapshot.documents.map { setDoc in
                try Firestore.Decoder().decode(WorkoutSetModel.self, from: setDoc.data())
            }
            
            exercise = exercise.withSets(sets)
            exercises.append(exercise)
        }
        
        return session.withExercises(exercises)
    }
    
    /// Retrieves multiple workout sessions by IDs
    func getWorkoutSessions(ids: [String], limitTo: Int = 20) async throws -> [WorkoutSessionModel] {
        var sessions: [WorkoutSessionModel] = []
        
        // Process in batches due to Firestore 'in' query limit of 10
        let batchSize = 10
        for iteration in stride(from: 0, to: ids.count, by: batchSize) {
            let batchIds = Array(ids[iteration..<min(iteration + batchSize, ids.count)])
            
            let query = collection.whereField(FieldPath.documentID(), in: batchIds)
            let snapshot = try await query.getDocuments()
            
            for document in snapshot.documents {
                let session = try await getWorkoutSession(id: document.documentID)
                sessions.append(session)
            }
        }
        
        return Array(sessions.shuffled().prefix(limitTo))
    }
    
    /// Retrieves workout sessions for a specific author and template
    func getWorkoutSessionsByTemplateAndAuthor(templateId: String, authorId: String, limitTo: Int) async throws -> [WorkoutSessionModel] {
        let query = collection
            .whereField(WorkoutSessionModel.CodingKeys.authorId.rawValue, isEqualTo: authorId)
            .whereField(WorkoutSessionModel.CodingKeys.workoutTemplateId.rawValue, isEqualTo: templateId)
            .order(by: WorkoutSessionModel.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: limitTo)
        
        let snapshot = try await query.getDocuments()
        var sessions: [WorkoutSessionModel] = []
        
        for document in snapshot.documents {
            let session = try await getWorkoutSession(id: document.documentID)
            sessions.append(session)
        }
        
        return sessions
    }
    
    /// Retrieves workout sessions for a specific author
    func getWorkoutSessionsForAuthor(authorId: String, limitTo: Int) async throws -> [WorkoutSessionModel] {
        let query = collection
            .whereField(WorkoutSessionModel.CodingKeys.authorId.rawValue, isEqualTo: authorId)
            .order(by: WorkoutSessionModel.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: limitTo)
        
        let snapshot = try await query.getDocuments()
        var sessions: [WorkoutSessionModel] = []
        
        for document in snapshot.documents {
            let session = try await getWorkoutSession(id: document.documentID)
            sessions.append(session)
        }
        
        return sessions
    }
    
    // MARK: - Update Operations
    
    /// Updates a workout session and its subcollections
    func updateWorkoutSession(session: WorkoutSessionModel) async throws {
        let database = Firestore.firestore()
        let batch = database.batch()
        
        let sessionDoc = collection.document(session.id)
        
        // Update session document
        let sessionData = try Firestore.Encoder().encode(session.forFirebaseStorage())
        batch.setData(sessionData, forDocument: sessionDoc, merge: true)
        
        // Update exercises and sets
        for exercise in session.exercises {
            let exerciseDoc = sessionDoc.collection("exercises").document(exercise.id)
            let exerciseData = try Firestore.Encoder().encode(exercise.forFirebaseStorage())
            batch.setData(exerciseData, forDocument: exerciseDoc, merge: true)
            
            // Update sets
            for set in exercise.sets {
                let setDoc = exerciseDoc.collection("sets").document(set.id)
                let setData = try Firestore.Encoder().encode(set)
                batch.setData(setData, forDocument: setDoc, merge: true)
            }
        }
        
        try await batch.commit()
    }
    
    /// Ends a workout session by setting the endedAt timestamp
    func endWorkoutSession(id: String, at endedAt: Date) async throws {
        try await collection.document(id).updateData([
            WorkoutSessionModel.CodingKeys.endedAt.rawValue: endedAt
        ])
    }
    
    // MARK: - Individual Set Operations
    
    /// Adds a new set to an exercise
    func addSet(to exerciseId: String, in sessionId: String, set: WorkoutSetModel) async throws {
        let setDoc = collection
            .document(sessionId)
            .collection("exercises")
            .document(exerciseId)
            .collection("sets")
            .document(set.id)
        
        try setDoc.setData(from: set, merge: true)
    }
    
    /// Updates a specific set
    func updateSet(setId: String, exerciseId: String, sessionId: String, set: WorkoutSetModel) async throws {
        let setDoc = collection
            .document(sessionId)
            .collection("exercises")
            .document(exerciseId)
            .collection("sets")
            .document(setId)
        
        try setDoc.setData(from: set, merge: true)
    }
    
    /// Deletes a specific set
    func deleteSet(setId: String, exerciseId: String, sessionId: String) async throws {
        try await collection
            .document(sessionId)
            .collection("exercises")
            .document(exerciseId)
            .collection("sets")
            .document(setId)
            .delete()
    }
    
    /// Gets all sets for a specific exercise
    func getSetsForExercise(exerciseId: String, sessionId: String) async throws -> [WorkoutSetModel] {
        let setsSnapshot = try await collection
            .document(sessionId)
            .collection("exercises")
            .document(exerciseId)
            .collection("sets")
            .order(by: "index")
            .getDocuments()
        
        return try setsSnapshot.documents.map { setDoc in
            try Firestore.Decoder().decode(WorkoutSetModel.self, from: setDoc.data())
        }
    }
    
    // MARK: - Delete Operations
    
    /// Deletes a workout session and all its subcollections
    func deleteWorkoutSession(id: String) async throws {
        let database = Firestore.firestore()
        let sessionDoc = collection.document(id)
        
        // Delete all sets in all exercises
        let exercisesSnapshot = try await sessionDoc.collection("exercises").getDocuments()
        
        for exerciseDoc in exercisesSnapshot.documents {
            let setsSnapshot = try await exerciseDoc.reference.collection("sets").getDocuments()
            
            // Delete sets in batches
            let batch = database.batch()
            for setDoc in setsSnapshot.documents {
                batch.deleteDocument(setDoc.reference)
            }
            try await batch.commit()
            
            // Delete exercise document
            try await exerciseDoc.reference.delete()
        }
        
        // Finally delete the session document
        try await sessionDoc.delete()
    }
    
    /// Deletes all workout sessions for an author
    func deleteAllWorkoutSessionsForAuthor(authorId: String) async throws {
        let sessions: [WorkoutSessionModel] = try await collection
            .whereField(WorkoutSessionModel.CodingKeys.authorId.rawValue, isEqualTo: authorId)
            .getAllDocuments()
        
        for session in sessions {
            try await deleteWorkoutSession(id: session.id)
        }
    }
}

// MARK: - Model Extensions for Firebase Storage

extension WorkoutSessionModel {
    /// Returns a version of the model suitable for Firebase storage (without nested exercises)
    func forFirebaseStorage() -> WorkoutSessionForFirebase {
        WorkoutSessionForFirebase(
            id: id,
            authorId: authorId,
            workoutTemplateId: workoutTemplateId,
            dateCreated: dateCreated,
            dateModified: dateModified,
            endedAt: endedAt,
            notes: notes
        )
    }
    
    /// Returns a new instance with the provided exercises
    func withExercises(_ exercises: [WorkoutExerciseModel]) -> WorkoutSessionModel {
        WorkoutSessionModel(
            id: id,
            authorId: authorId,
            name: name,
            workoutTemplateId: workoutTemplateId,
            dateCreated: dateCreated,
            dateModified: dateModified,
            endedAt: endedAt,
            notes: notes,
            exercises: exercises
        )
    }
}

extension WorkoutExerciseModel {
    /// Returns a version of the model suitable for Firebase storage (without nested sets)
    func forFirebaseStorage() -> WorkoutExerciseForFirebase {
        WorkoutExerciseForFirebase(
            id: id,
            authorId: authorId,
            templateId: templateId,
            name: name,
            trackingMode: trackingMode,
            notes: notes
        )
    }
    
    /// Returns a new instance with the provided sets
    func withSets(_ sets: [WorkoutSetModel]) -> WorkoutExerciseModel {
        WorkoutExerciseModel(
            id: id,
            authorId: authorId,
            templateId: templateId,
            name: name,
            trackingMode: trackingMode,
            notes: notes,
            sets: sets
        )
    }
}

// MARK: - Firebase Storage Models

/// Simplified WorkoutSession model for Firebase storage without nested collections
struct WorkoutSessionForFirebase: Codable {
    let id: String
    let authorId: String
    let workoutTemplateId: String?
    let dateCreated: Date
    let dateModified: Date
    let endedAt: Date?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case workoutTemplateId = "workout_template_id"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case endedAt = "ended_at"
        case notes
    }
}

/// Simplified WorkoutExercise model for Firebase storage without nested sets
struct WorkoutExerciseForFirebase: Codable {
    let id: String
    let authorId: String
    let templateId: String
    let name: String
    let trackingMode: TrackingMode
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case templateId = "template_id"
        case name
        case trackingMode = "tracking_mode"
        case notes
    }
}
