//
//  WorkoutTemplateListPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutTemplateListPresenter {
    private let interactor: WorkoutTemplateListInteractor
    private let router: WorkoutTemplateListRouter
    
    private(set) var isLoading: Bool = true
    
    private(set) var myWorkouts: [WorkoutTemplateModel] = []
    private(set) var favouriteWorkouts: [WorkoutTemplateModel] = []
    private(set) var bookmarkedWorkouts: [WorkoutTemplateModel] = []
    private(set) var systemWorkouts: [WorkoutTemplateModel] = []

    var hasWorkouts: Bool {
        if myWorkouts.isEmpty && favouriteWorkouts.isEmpty && bookmarkedWorkouts.isEmpty && systemWorkouts.isEmpty {
            false
        } else {
            true
        }
    }
    
    init(
        interactor: WorkoutTemplateListInteractor,
        router: WorkoutTemplateListRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onWorkoutPressed(template: WorkoutTemplateModel) {
        router.showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate(workoutTemplate: template))
    }
    
    func onCreateWorkoutPressed() {
        router.showCreateWorkoutView(delegate: CreateWorkoutDelegate())
    }
}
