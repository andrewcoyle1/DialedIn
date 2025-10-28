//
//  ExerciseSeedingManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import Foundation
import SwiftData

/// Manages seeding of pre-built exercise templates into SwiftData
@MainActor
class ExerciseSeedingManager {
    
    private let modelContext: ModelContext
    private let userDefaults = UserDefaults.standard
    private static let hasSeededKey = "hasSeededPrebuiltExercises"
    private static let seedingVersionKey = "prebuiltExercisesSeedingVersion"
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
            let exercises = try loadPrebuiltExercises()
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
    private func loadPrebuiltExercises() throws -> [ExerciseTemplateModel] {
        guard let url = Bundle.main.url(forResource: "PrebuiltExercises", withExtension: "json") else {
            throw SeedingError.bundleNotFound
        }
        
        let data = try Data(contentsOf: url)
        let container = try JSONDecoder().decode(PrebuiltExercisesContainer.self, from: data)
        
        // Convert DTOs to models
        let exercises = container.exercises.map { $0.toModel() }
        
        return exercises
    }
    
    /// Seed exercises into SwiftData
    private func seedExercises(_ exercises: [ExerciseTemplateModel]) throws {
        for exercise in exercises {
            // Check if this system exercise already exists
            let exerciseId = exercise.exerciseId // Capture in local variable
            let predicate = #Predicate<ExerciseTemplateEntity> { entity in
                entity.exerciseTemplateId == exerciseId
            }
            
            let descriptor = FetchDescriptor<ExerciseTemplateEntity>(predicate: predicate)
            let existing = try modelContext.fetch(descriptor)
            
            // Only insert if doesn't exist
            if existing.isEmpty {
                let entity = ExerciseTemplateEntity(from: exercise)
                modelContext.insert(entity)
            } else {
                print("⚠️ System exercise '\(exercise.name)' already exists, skipping")
            }
        }
        
        // Save all changes
        try modelContext.save()
    }
    
    /// Delete existing system exercises
    private func deleteExistingSystemExercises() throws {
        let predicate = #Predicate<ExerciseTemplateEntity> { entity in
            entity.isSystemExercise == true
        }
        
        let descriptor = FetchDescriptor<ExerciseTemplateEntity>(predicate: predicate)
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
    let exercises: [PrebuiltExerciseDTO]
}

/// DTO for decoding JSON (without date fields)
private struct PrebuiltExerciseDTO: Codable {
    let exerciseId: String
    let name: String
    let description: String?
    let type: ExerciseCategory
    let muscleGroups: [MuscleGroup]
    let instructions: [String]
    let isSystemExercise: Bool
    
    func toModel() -> ExerciseTemplateModel {
        // Try to map to bundled asset image
        let assetImageName = Constants.exerciseImageName(for: name)
        return ExerciseTemplateModel(
            exerciseId: exerciseId,
            authorId: nil,
            name: name,
            description: description,
            instructions: instructions,
            type: type,
            muscleGroups: muscleGroups,
            imageURL: assetImageName,
            isSystemExercise: isSystemExercise,
            dateCreated: Date(),
            dateModified: Date(),
            clickCount: 0,
            bookmarkCount: 0,
            favouriteCount: 0
        )
    }
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
