//
//  ProductionExerciseHistoryServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionExerciseHistoryServices: ExerciseHistoryServices {
    let remote: RemoteExerciseHistoryService
    let local: LocalExerciseHistoryPersistence
    
    @MainActor
    init() {
        self.remote = FirebaseExerciseHistoryService()
        self.local = SwiftExerciseHistoryPersistence()
    }
}
