//
//  WorkoutSeedingManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation
import SwiftData

/// Manages seeding of pre-built workout templates into SwiftData
class WorkoutSeedingManager {
    
    private let modelContext: ModelContext
    private let exerciseManager: ExerciseTemplateManager
    private let userDefaults = UserDefaults.standard
    private static let hasSeededKey = "hasSeededPrebuiltWorkouts"
    private static let seedingVersionKey = "prebuiltWorkoutsSeedingVersion"
    private static let currentSeedingVersion = 1
    
    init(modelContext: ModelContext, exerciseManager: ExerciseTemplateManager) {
        self.modelContext = modelContext
        self.exerciseManager = exerciseManager
    }
    
    /// Check if workouts have already been seeded
    var hasSeeded: Bool {
        userDefaults.bool(forKey: Self.hasSeededKey)
    }
    
    /// Get the current seeding version
    var seedingVersion: Int {
        userDefaults.integer(forKey: Self.seedingVersionKey)
    }
    
    /// Seed pre-built workouts if not already seeded
    func seedWorkoutsIfNeeded() async throws {
        // Skip if already seeded with current version
        guard !hasSeeded || seedingVersion < Self.currentSeedingVersion else {
            print("✅ Pre-built workouts already seeded (version \(seedingVersion))")
            return
        }
        
        // Wait for exercises to be seeded first (small delay to ensure they're available)
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Verify we have some exercises available before attempting to seed workouts
        let exerciseCount = (try? exerciseManager.getAllLocalExerciseTemplates().count) ?? 0
        guard exerciseCount > 0 else {
            print("⚠️ No exercises available yet, deferring workout seeding...")
            // Retry in a moment
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 more seconds
                try? await self.seedWorkoutsIfNeeded()
            }
            return
        }
        
        print("🌱 Seeding pre-built workouts (found \(exerciseCount) exercises available)...")
        
        do {
            let workouts = try await loadPrebuiltWorkouts()
            try await seedWorkouts(workouts)
            
            // Mark as seeded
            userDefaults.set(true, forKey: Self.hasSeededKey)
            userDefaults.set(Self.currentSeedingVersion, forKey: Self.seedingVersionKey)
            
            print("✅ Successfully seeded \(workouts.count) pre-built workouts")
        } catch {
            print("❌ Failed to seed workouts: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Force re-seed workouts (useful for development/testing)
    func resetAndReseed() async throws {
        print("🔄 Resetting and re-seeding workouts...")
        
        // Delete existing system workouts
        try deleteExistingSystemWorkouts()
        
        // Reset seeding flags
        userDefaults.removeObject(forKey: Self.hasSeededKey)
        userDefaults.removeObject(forKey: Self.seedingVersionKey)
        
        // Seed again
        try await seedWorkoutsIfNeeded()
    }
    
    // MARK: - Private Methods
    
    /// Load pre-built workouts from JSON bundle
    private func loadPrebuiltWorkouts() async throws -> [WorkoutTemplateModel] {
        guard let url = Bundle.main.url(forResource: "PrebuiltWorkouts", withExtension: "json") else {
            throw SeedingError.bundleNotFound
        }
        
        let data = try Data(contentsOf: url)
        let container = try JSONDecoder().decode(PrebuiltWorkoutsContainer.self, from: data)
        
        // Convert DTOs to models with actual exercise templates
        var workouts: [WorkoutTemplateModel] = []
        for dto in container.workouts {
            let workout = try await dto.toModel(exerciseManager: exerciseManager)
            workouts.append(workout)
        }
        
        return workouts
    }
    
    /// Seed workouts into SwiftData
    private func seedWorkouts(_ workouts: [WorkoutTemplateModel]) async throws {
        for workout in workouts {
            // Check if this system workout already exists
            let workoutId = workout.workoutId
            let predicate = #Predicate<WorkoutTemplateEntity> { entity in
                entity.workoutTemplateId == workoutId
            }
            
            let descriptor = FetchDescriptor<WorkoutTemplateEntity>(predicate: predicate)
            let existing = try modelContext.fetch(descriptor)
            
            // Only insert if doesn't exist
            if existing.isEmpty {
                let entity = WorkoutTemplateEntity(from: workout)
                modelContext.insert(entity)
                print("  ✓ Seeded workout: \(workout.name)")
            } else {
                print("  ⚠️ System workout '\(workout.name)' already exists, skipping")
            }
        }
        
        // Save all changes
        try modelContext.save()
    }
    
    /// Delete existing system workouts
    private func deleteExistingSystemWorkouts() throws {
        let predicate = #Predicate<WorkoutTemplateEntity> { entity in
            entity.isSystemWorkout == true
        }
        
        let descriptor = FetchDescriptor<WorkoutTemplateEntity>(predicate: predicate)
        let systemWorkouts = try modelContext.fetch(descriptor)
        
        for workout in systemWorkouts {
            modelContext.delete(workout)
        }
        
        try modelContext.save()
        print("🗑️ Deleted \(systemWorkouts.count) existing system workouts")
    }
}

// MARK: - Supporting Types

/// Container for decoding JSON
private struct PrebuiltWorkoutsContainer: Codable {
    let workouts: [PrebuiltWorkoutDTO]
}

/// DTO for decoding JSON (without date fields)
private struct PrebuiltWorkoutDTO: Codable {
    let workoutId: String
    let name: String
    let description: String?
    let isSystemWorkout: Bool
    let exerciseIds: [String]
    
    func toModel(exerciseManager: ExerciseTemplateManager) async throws -> WorkoutTemplateModel {
        // Fetch actual exercise templates from LOCAL storage (where they were seeded)
        var exercises: [ExerciseModel] = []
        for exerciseId in exerciseIds {
            do {
                // Use local fetch instead of remote
                let exercise = try exerciseManager.getLocalExerciseTemplate(id: exerciseId)
                exercises.append(exercise)
            } catch {
                print("⚠️ Warning: Exercise '\(exerciseId)' not found in local storage, skipping")
            }
        }
        
        guard !exercises.isEmpty else {
            print("❌ Warning: Workout '\(name)' has no exercises - all exercise IDs were invalid")
            throw URLError(.unknown)
        }
        
        return WorkoutTemplateModel(
            id: workoutId,
            authorId: "official",
            name: name,
            description: description,
            imageURL: nil,
            isSystemWorkout: isSystemWorkout,
            dateCreated: Date(),
            dateModified: Date(),
            exercises: exercises,
            clickCount: 0,
            bookmarkCount: 0,
            favouriteCount: 0
        )
    }
}

/// Errors that can occur during seeding
enum WorkoutSeedingError: LocalizedError {
    case bundleNotFound
    case decodingFailed(Error)
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .bundleNotFound:
            return "PrebuiltWorkouts.json not found in app bundle"
        case .decodingFailed(let error):
            return "Failed to decode workouts: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save workouts: \(error.localizedDescription)"
        }
    }
}
