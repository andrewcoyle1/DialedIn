//
//  ExerciseTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/09/2025.
//

protocol ExerciseTemplateServices {
    var remote: RemoteExerciseTemplateService { get }
    var local: LocalExerciseTemplatePersistence { get }
}

struct MockExerciseTemplateServices: ExerciseTemplateServices {
    let remote: RemoteExerciseTemplateService
    let local: LocalExerciseTemplatePersistence
    
    init(exercises: [ExerciseTemplateModel] = ExerciseTemplateModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.remote = MockExerciseTemplateService(exercises: exercises, delay: delay, showError: showError)
        self.local = MockExerciseTemplatePersistence(exercises: exercises, showError: showError)
    }
}

struct ProductionExerciseTemplateServices: ExerciseTemplateServices {
    let remote: RemoteExerciseTemplateService
    let local: LocalExerciseTemplatePersistence
    
    init() {
        self.remote = FirebaseExerciseTemplateService()
        self.local = SwiftExerciseTemplatePersistence()
    }
}
