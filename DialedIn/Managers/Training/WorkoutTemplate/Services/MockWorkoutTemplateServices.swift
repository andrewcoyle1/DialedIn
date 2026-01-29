//
//  MockWorkoutTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockWorkoutTemplateServices: WorkoutTemplateServices {
    let remote: RemoteWorkoutTemplateService
    let local: LocalWorkoutTemplatePersistence
    
    init(workouts: [WorkoutTemplateModel] = WorkoutTemplateModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.remote = MockWorkoutTemplateService(workouts: workouts, delay: delay, showError: showError)
        self.local = MockWorkoutTemplatePersistence(workouts: workouts, showError: showError)
    }
}
