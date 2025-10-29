//
//  ProductionWorkoutTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

@MainActor
struct ProductionWorkoutTemplateServices: WorkoutTemplateServices {
    let remote: RemoteWorkoutTemplateService
    let local: LocalWorkoutTemplatePersistence
    private var seedingManager: WorkoutSeedingManager?
    
    init(exerciseManager: ExerciseTemplateManager) {
        self.remote = FirebaseWorkoutTemplateService()
        let swiftPersistence = SwiftWorkoutTemplatePersistence(exerciseManager: exerciseManager)
        self.local = swiftPersistence
        
        // Initialize seeding manager and trigger seeding
        let manager = WorkoutSeedingManager(
            modelContext: swiftPersistence.modelContext,
            exerciseManager: exerciseManager
        )
        self.seedingManager = manager
        Task {
            try? await manager.seedWorkoutsIfNeeded()
        }
    }
}
