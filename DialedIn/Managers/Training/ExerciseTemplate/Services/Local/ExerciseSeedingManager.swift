//
//  ExerciseSeedingManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import Foundation
import SwiftData

/// Manages seeding of pre-built exercises into SwiftData
class ExerciseSeedingManager {
    
    private let modelContext: ModelContext
    private let userDefaults = UserDefaults.standard
    private static let hasSeededKey = "hasSeededPrebuiltExercisesV2"
    private static let seedingVersionKey = "prebuiltExercisesSeedingVersionV2"
    private static let currentSeedingVersion = 2
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Check if exercises have already been seeded
    var hasSeeded: Bool {
        userDefaults.bool(forKey: Self.hasSeededKey)
    }
    
    /// Get the current seeding version
    var seedingVersion: Int {
        userDefaults.integer(forKey: Self.seedingVersionKey)
    }
    
    /// Seed pre-built exercises if not already seeded
    func seedExercisesIfNeeded() async throws {
        // Skip if already seeded with current version
        guard !hasSeeded || seedingVersion < Self.currentSeedingVersion else {
            print("✅ Pre-built exercises already seeded (version \(seedingVersion))")
            return
        }
        
        print("🌱 Seeding pre-built exercises...")
        
        do {
            let exercises = try await loadPrebuiltExercises()
            try seedExercises(exercises)
            
            // Mark as seeded
            userDefaults.set(true, forKey: Self.hasSeededKey)
            userDefaults.set(Self.currentSeedingVersion, forKey: Self.seedingVersionKey)
            
            print("✅ Successfully seeded \(exercises.count) pre-built exercises")
        } catch {
            print("❌ Failed to seed exercises: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Force re-seed exercises (useful for development/testing)
    func resetAndReseed() async throws {
        print("🔄 Resetting and re-seeding exercises...")
        
        // Delete existing system exercises
        try deleteExistingSystemExercises()
        
        // Reset seeding flags
        userDefaults.removeObject(forKey: Self.hasSeededKey)
        userDefaults.removeObject(forKey: Self.seedingVersionKey)
        
        // Seed again
        try await seedExercisesIfNeeded()
    }
    
    // MARK: - Private Methods
    
    /// Load pre-built exercises from JSON bundle
    private func loadPrebuiltExercises() async throws -> [ExerciseModel] {
        guard let url = Bundle.main.url(forResource: "PrebuiltExercises", withExtension: "json") else {
            throw SeedingError.bundleNotFound
        }
        
        let data = try Data(contentsOf: url)
        let container = try JSONDecoder().decode(PrebuiltExercisesContainer.self, from: data)
        return container.exercises
    }
    
    /// Seed exercises into SwiftData
    private func seedExercises(_ exercises: [ExerciseModel]) throws {
        for exercise in exercises {
            // Check if this system exercise already exists
            let exerciseId = exercise.id // Capture in local variable
            let predicate = #Predicate<ExerciseEntity> { entity in
                entity.exerciseId == exerciseId
            }
            
            let descriptor = FetchDescriptor<ExerciseEntity>(predicate: predicate)
            let existing = try modelContext.fetch(descriptor)
            
            // Insert if missing; otherwise update to keep prebuilt fields current
            if let entity = existing.first {
                updateExistingSystemExercise(entity: entity, with: exercise)
            } else {
                let entity = ExerciseEntity(from: exercise)
                modelContext.insert(entity)
            }
        }
        
        // Save all changes
        try modelContext.save()
    }
    
    private func updateExistingSystemExercise(entity: ExerciseEntity, with model: ExerciseModel) {
        entity.authorId = model.authorId
        entity.name = model.name
        entity.exerciseDescription = model.description
        entity.imageURL = model.imageURL
        
        entity.trackableMetrics = Self.encode(model.trackableMetrics)
        entity.typeRaw = model.type?.rawValue
        entity.lateralityRaw = model.laterality?.rawValue
        entity.muscleGroups = Self.encode(model.muscleGroups)
        entity.isBodyweight = model.isBodyweight
        entity.resistanceEquipment = Self.encode(model.resistanceEquipment)
        entity.supportEquipment = Self.encode(model.supportEquipment)
        entity.rangeOfMotion = model.rangeOfMotion
        entity.stability = model.stability
        entity.bodyWeightContribution = model.bodyWeightContribution
        entity.alternateNames = Self.encode(model.alternateNames)
        
        entity.isSystemExercise = model.isSystemExercise
        entity.dateModified = .now
        
        // Preserve local counters (click/bookmark/favourite) if present
        if entity.clickCount == nil { entity.clickCount = model.clickCount ?? 0 }
        if entity.bookmarkCount == nil { entity.bookmarkCount = model.bookmarkCount ?? 0 }
        if entity.favouriteCount == nil { entity.favouriteCount = model.favouriteCount ?? 0 }
    }
    
    private static func encode<T: Encodable>(_ value: T) -> Data {
        (try? JSONEncoder().encode(value)) ?? Data()
    }
    
    /// Delete existing system exercises
    private func deleteExistingSystemExercises() throws {
        let predicate = #Predicate<ExerciseEntity> { entity in
            entity.isSystemExercise == true
        }
        
        let descriptor = FetchDescriptor<ExerciseEntity>(predicate: predicate)
        let systemExercises = try modelContext.fetch(descriptor)
        
        for exercise in systemExercises {
            modelContext.delete(exercise)
        }
        
        try modelContext.save()
        print("🗑️ Deleted \(systemExercises.count) existing system exercises")
    }
}

// MARK: - Supporting Types

/// Container for decoding JSON
private struct PrebuiltExercisesContainer: Codable {
    let exercises: [ExerciseModel]
}

/// Errors that can occur during seeding
enum SeedingError: LocalizedError {
    case bundleNotFound
    case decodingFailed(Error)
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .bundleNotFound:
            return "PrebuiltExercises.json not found in app bundle"
        case .decodingFailed(let error):
            return "Failed to decode exercises: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save exercises: \(error.localizedDescription)"
        }
    }
}
