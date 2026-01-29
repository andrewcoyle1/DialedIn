//
//  MockExerciseTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockExerciseTemplateServices: ExerciseTemplateServices {
    let remote: RemoteExerciseTemplateService
    let local: LocalExerciseTemplatePersistence
    
    init(exercises: [ExerciseTemplateModel] = ExerciseTemplateModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.remote = MockExerciseTemplateService(exercises: exercises, delay: delay, showError: showError)
        self.local = MockExerciseTemplatePersistence(exercises: exercises, showError: showError)
    }
}
