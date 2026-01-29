//
//  MockExerciseHistoryServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockExerciseHistoryServices: ExerciseHistoryServices {
    let remote: RemoteExerciseHistoryService
    let local: LocalExerciseHistoryPersistence
    
    init(entries: [ExerciseHistoryEntryModel] = ExerciseHistoryEntryModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.remote = MockExerciseHistoryService(entries: entries, delay: delay, showError: showError)
        self.local = MockExerciseHistoryPersistence(entries: entries, showError: showError)
    }
}
