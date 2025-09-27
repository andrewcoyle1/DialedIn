//
//  ExerciseHistoryServices.swift
//  DialedIn
//
//  Created by AI Assistant on 27/09/2025.
//

protocol ExerciseHistoryServices {
    var remote: RemoteExerciseHistoryService { get }
    var local: LocalExerciseHistoryPersistence { get }
}

struct MockExerciseHistoryServices: ExerciseHistoryServices {
    let remote: RemoteExerciseHistoryService
    let local: LocalExerciseHistoryPersistence
    
    init(entries: [ExerciseHistoryEntryModel] = ExerciseHistoryEntryModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.remote = MockExerciseHistoryService(entries: entries, delay: delay, showError: showError)
        self.local = MockExerciseHistoryPersistence(entries: entries, showError: showError)
    }
}

struct ProductionExerciseHistoryServices: ExerciseHistoryServices {
    let remote: RemoteExerciseHistoryService
    let local: LocalExerciseHistoryPersistence
    
    init() {
        self.remote = FirebaseExerciseHistoryService()
        self.local = SwiftExerciseHistoryPersistence()
    }
}
