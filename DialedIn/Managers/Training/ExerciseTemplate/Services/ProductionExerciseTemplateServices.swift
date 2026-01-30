//
//  ProductionExerciseTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionExerciseTemplateServices: ExerciseTemplateServices {
    let remote: RemoteExerciseTemplateService
    let local: LocalExercisePersistence
    private var seedingManager: ExerciseSeedingManager?
    
    @MainActor
    init() {
        self.remote = FirebaseExerciseTemplateService()
        let swiftPersistence = SwiftExercisePersistence()
        self.local = swiftPersistence
        
        // Initialize seeding manager and trigger seeding
        let manager = ExerciseSeedingManager(modelContext: swiftPersistence.modelContext)
        self.seedingManager = manager
        Task {
            try? await manager.seedExercisesIfNeeded()
        }
    }
}
