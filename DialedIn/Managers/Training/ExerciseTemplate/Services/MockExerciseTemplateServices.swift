//
//  MockExerciseTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockExerciseTemplateServices: ExerciseTemplateServices {
    let remote: RemoteExerciseTemplateService
    let local: LocalExercisePersistence
    
    init(exercises: [ExerciseModel] = ExerciseModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.remote = MockExerciseTemplateService(exercises: exercises, delay: delay, showError: showError)
        self.local = MockExercisePersistence(exercises: exercises, showError: showError)
    }
}
