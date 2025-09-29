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
    
    private var exercisesCollection: CollectionReference {
        Firestore.firestore().collection("workout_exercises")
    }
    
    private var setsCollection: CollectionReference {
        Firestore.firestore().collection("workout_sets")
    }
    
    // MARK: - Create Operations
    
    /// Creates a workout session with related exercises/sets stored in flattened top-level collections
    func createWorkoutSession(session: WorkoutSessionModel) async throws {
        let database = Firestore.firestore()
        let batch = database.batch()
        
        // Create session document (no nested data)
        let sessionDoc = collection.document(session.id)
        let sessionData = try Firestore.Encoder().encode(session.forFirebaseStorage())
        batch.setData(sessionData, forDocument: sessionDoc, merge: true)
        
        // Create flattened workout_exercises and workout_sets documents
        for (exerciseOrder, exercise) in session.exercises.enumerated() {
            let exerciseRecord = WorkoutExerciseRecord(
                id: exercise.id,
                sessionId: session.id,
                authorId: exercise.authorId,
                templateId: exercise.templateId,
                name: exercise.name,
                trackingMode: exercise.trackingMode,
                notes: exercise.notes,
                order: exerciseOrder
            )
            let exerciseData = try Firestore.Encoder().encode(exerciseRecord)
            batch.setData(exerciseData, forDocument: exercisesCollection.document(exercise.id), merge: true)
            
            for set in exercise.sets {
                let setRecord = WorkoutSetRecord(
                    id: set.id,
                    sessionId: session.id,
                    exerciseId: exercise.id,
                    authorId: set.authorId,
                    setIndex: set.index,
                    reps: set.reps,
                    weightKg: set.weightKg,
                    durationSec: set.durationSec,
                    distanceMeters: set.distanceMeters,
                    rpe: set.rpe,
                    isWarmup: set.isWarmup,
                    completedAt: set.completedAt,
                    dateCreated: set.dateCreated,
                    templateId: exercise.templateId
                )
                let setData = try Firestore.Encoder().encode(setRecord)
                batch.setData(setData, forDocument: setsCollection.document(set.id), merge: true)
            }
        }
        
        try await batch.commit()
    }
    
    // MARK: - Read Operations
    
    /// Retrieves a complete workout session including all exercises and sets (flattened collections)
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel {
        // Get session data
        let sessionSnapshot = try await collection.document(id).getDocument()
        guard let sessionData = sessionSnapshot.data() else {
            throw NSError(domain: "FirebaseWorkoutSessionService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Workout session not found"])
        }
        
        // Decode base session (expects the document to contain compatible fields)
        let baseSession = try Firestore.Decoder().decode(WorkoutSessionModel.self, from: sessionData)
        
        // Fetch exercises from flattened collection
        let exercisesSnapshot = try await exercisesCollection
            .whereField(WorkoutExerciseRecord.CodingKeys.sessionId.rawValue, isEqualTo: id)
            .order(by: WorkoutExerciseRecord.CodingKeys.order.rawValue)
            .getDocuments()
        
        var exercises: [WorkoutExerciseModel] = []
        for exerciseDoc in exercisesSnapshot.documents {
            let record = try Firestore.Decoder().decode(WorkoutExerciseRecord.self, from: exerciseDoc.data())
            
            // Fetch sets for this exercise
            let setsSnapshot = try await setsCollection
                .whereField(WorkoutSetRecord.CodingKeys.sessionId.rawValue, isEqualTo: id)
                .whereField(WorkoutSetRecord.CodingKeys.exerciseId.rawValue, isEqualTo: record.id)
                .order(by: WorkoutSetRecord.CodingKeys.setIndex.rawValue)
                .getDocuments()
            let setRecords: [WorkoutSetRecord] = try setsSnapshot.documents.map { setDoc in
                try Firestore.Decoder().decode(WorkoutSetRecord.self, from: setDoc.data())
            }
            let sets: [WorkoutSetModel] = setRecords.map { srecord in
                WorkoutSetModel(
                    id: srecord.id,
                    authorId: srecord.authorId,
                    index: srecord.setIndex,
                    reps: srecord.reps,
                    weightKg: srecord.weightKg,
                    durationSec: srecord.durationSec,
                    distanceMeters: srecord.distanceMeters,
                    rpe: srecord.rpe,
                    isWarmup: srecord.isWarmup,
                    completedAt: srecord.completedAt,
                    dateCreated: srecord.dateCreated
                )
            }
            let exercise = WorkoutExerciseModel(
                id: record.id,
                authorId: record.authorId,
                templateId: record.templateId,
                name: record.name,
                trackingMode: record.trackingMode,
                notes: record.notes,
                sets: sets
            )
            exercises.append(exercise)
        }
        
        return baseSession.withExercises(exercises)
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
    
    /// Updates a workout session and related flattened collections
    func updateWorkoutSession(session: WorkoutSessionModel) async throws {
        let database = Firestore.firestore()
        let batch = database.batch()
        
        let sessionDoc = collection.document(session.id)
        
        // Update session document
        let sessionData = try Firestore.Encoder().encode(session.forFirebaseStorage())
        batch.setData(sessionData, forDocument: sessionDoc, merge: true)
        
        // Upsert flattened workout_exercises and workout_sets documents
        for (exerciseOrder, exercise) in session.exercises.enumerated() {
            let exerciseRecord = WorkoutExerciseRecord(
                id: exercise.id,
                sessionId: session.id,
                authorId: exercise.authorId,
                templateId: exercise.templateId,
                name: exercise.name,
                trackingMode: exercise.trackingMode,
                notes: exercise.notes,
                order: exerciseOrder
            )
            let exerciseData = try Firestore.Encoder().encode(exerciseRecord)
            batch.setData(exerciseData, forDocument: exercisesCollection.document(exercise.id), merge: true)
            
            for set in exercise.sets {
                let setRecord = WorkoutSetRecord(
                    id: set.id,
                    sessionId: session.id,
                    exerciseId: exercise.id,
                    authorId: set.authorId,
                    setIndex: set.index,
                    reps: set.reps,
                    weightKg: set.weightKg,
                    durationSec: set.durationSec,
                    distanceMeters: set.distanceMeters,
                    rpe: set.rpe,
                    isWarmup: set.isWarmup,
                    completedAt: set.completedAt,
                    dateCreated: set.dateCreated,
                    templateId: exercise.templateId
                )
                let setData = try Firestore.Encoder().encode(setRecord)
                batch.setData(setData, forDocument: setsCollection.document(set.id), merge: true)
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
    
    /// Adds a new set to an exercise (flattened collection)
    func addSet(to exerciseId: String, in sessionId: String, set: WorkoutSetModel) async throws {
        let record = WorkoutSetRecord(
            id: set.id,
            sessionId: sessionId,
            exerciseId: exerciseId,
            authorId: set.authorId,
            setIndex: set.index,
            reps: set.reps,
            weightKg: set.weightKg,
            durationSec: set.durationSec,
            distanceMeters: set.distanceMeters,
            rpe: set.rpe,
            isWarmup: set.isWarmup,
            completedAt: set.completedAt,
            dateCreated: set.dateCreated,
            templateId: nil
        )
        try setsCollection.document(set.id).setData(from: record, merge: true)
    }
    
    /// Updates a specific set (flattened collection)
    func updateSet(setId: String, exerciseId: String, sessionId: String, set: WorkoutSetModel) async throws {
        let record = WorkoutSetRecord(
            id: setId,
            sessionId: sessionId,
            exerciseId: exerciseId,
            authorId: set.authorId,
            setIndex: set.index,
            reps: set.reps,
            weightKg: set.weightKg,
            durationSec: set.durationSec,
            distanceMeters: set.distanceMeters,
            rpe: set.rpe,
            isWarmup: set.isWarmup,
            completedAt: set.completedAt,
            dateCreated: set.dateCreated,
            templateId: nil
        )
        try setsCollection.document(setId).setData(from: record, merge: true)
    }
    
    /// Deletes a specific set (flattened collection)
    func deleteSet(setId: String, exerciseId: String, sessionId: String) async throws {
        try await setsCollection.document(setId).delete()
    }
    
    /// Gets all sets for a specific exercise (flattened collection)
    func getSetsForExercise(exerciseId: String, sessionId: String) async throws -> [WorkoutSetModel] {
        let setsSnapshot = try await setsCollection
            .whereField(WorkoutSetRecord.CodingKeys.sessionId.rawValue, isEqualTo: sessionId)
            .whereField(WorkoutSetRecord.CodingKeys.exerciseId.rawValue, isEqualTo: exerciseId)
            .order(by: WorkoutSetRecord.CodingKeys.setIndex.rawValue)
            .getDocuments()
        
        let records: [WorkoutSetRecord] = try setsSnapshot.documents.map { doc in
            try Firestore.Decoder().decode(WorkoutSetRecord.self, from: doc.data())
        }
        return records.map { record in
            WorkoutSetModel(
                id: record.id,
                authorId: record.authorId,
                index: record.setIndex,
                reps: record.reps,
                weightKg: record.weightKg,
                durationSec: record.durationSec,
                distanceMeters: record.distanceMeters,
                rpe: record.rpe,
                isWarmup: record.isWarmup,
                completedAt: record.completedAt,
                dateCreated: record.dateCreated
            )
        }
    }
    
    // MARK: - Delete Operations
    
    /// Deletes a workout session and all related top-level records (flattened schema)
    func deleteWorkoutSession(id: String) async throws {
        let database = Firestore.firestore()
        
        // 1) Delete all workout_sets for this session
        do {
            let setsQuery = Firestore.firestore()
                .collection("workout_sets")
                .whereField(WorkoutSetRecord.CodingKeys.sessionId.rawValue, isEqualTo: id)
            let setsSnapshot = try await setsQuery.getDocuments()
            let batch = database.batch()
            for doc in setsSnapshot.documents { batch.deleteDocument(doc.reference) }
            if !setsSnapshot.isEmpty { try await batch.commit() }
        }
        
        // 2) Delete all workout_exercises for this session
        do {
            let exercisesQuery = Firestore.firestore()
                .collection("workout_exercises")
                .whereField(WorkoutExerciseRecord.CodingKeys.sessionId.rawValue, isEqualTo: id)
            let exercisesSnapshot = try await exercisesQuery.getDocuments()
            let batch = database.batch()
            for doc in exercisesSnapshot.documents { batch.deleteDocument(doc.reference) }
            if !exercisesSnapshot.isEmpty { try await batch.commit() }
        }
        
        // 3) Delete the workout_sessions document
        try await collection.document(id).delete()
    }
    
    /// Deletes all workout sessions for an author
    func deleteAllWorkoutSessionsForAuthor(authorId: String) async throws {
        // Fetch by document snapshot to avoid decoding into full model (storage uses simplified fields)
        let snapshot = try await collection
            .whereField(WorkoutSessionModel.CodingKeys.authorId.rawValue, isEqualTo: authorId)
            .getDocuments()
        
        for document in snapshot.documents {
            try await deleteWorkoutSession(id: document.documentID)
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
