//
//  WorkoutTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/09/2025.
//

protocol WorkoutTemplateServices {
    var remote: RemoteWorkoutTemplateService { get }
    var local: LocalWorkoutTemplatePersistence { get }
}

struct MockWorkoutTemplateServices: WorkoutTemplateServices {
    let remote: RemoteWorkoutTemplateService
    let local: LocalWorkoutTemplatePersistence
    
    init(workouts: [WorkoutTemplateModel] = WorkoutTemplateModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.remote = MockWorkoutTemplateService(workouts: workouts, delay: delay, showError: showError)
        self.local = MockWorkoutTemplatePersistence(workouts: workouts, showError: showError)
    }
}

struct ProductionWorkoutTemplateServices: WorkoutTemplateServices {
    let remote: RemoteWorkoutTemplateService
    let local: LocalWorkoutTemplatePersistence
    
    init(exerciseManager: ExerciseTemplateManager) {
        self.remote = FirebaseWorkoutTemplateService()
        self.local = SwiftWorkoutTemplatePersistence(exerciseManager: exerciseManager)
    }
}
