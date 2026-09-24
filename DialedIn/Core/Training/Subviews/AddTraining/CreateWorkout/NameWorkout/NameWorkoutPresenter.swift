//
//  NameWorkoutPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class NameWorkoutPresenter {
    
    private let interactor: NameWorkoutInteractor
    private let router: NameWorkoutRouter
    
    var workoutName: String
    var canSave: Bool {
        !workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(
        interactor: NameWorkoutInteractor,
        router: NameWorkoutRouter,
        workoutName: String = ""
    ) {
        self.interactor = interactor
        self.router = router
        self.workoutName = workoutName
    }
        
    /// A template being edited already has a gym, so that step is skipped when the gym still exists.
    func onContinuePressed(delegate: NameWorkoutDelegate) {
        let name = workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let template = delegate.workoutTemplate,
           let gym = interactor.gymProfiles.first(where: { $0.id == template.gymProfileId }) {
            router.showDefineWorkoutWrapperView(
                delegate: DefineWorkoutWrapperDelegate(
                    name: name,
                    gymProfile: gym,
                    workoutTemplate: template,
                    onWorkoutCreated: delegate.onWorkoutCreated
                )
            )
        } else {
            router.showChooseGymProfileView(
                delegate: ChooseGymProfileDelegate(
                    name: name,
                    workoutTemplate: delegate.workoutTemplate,
                    onWorkoutCreated: delegate.onWorkoutCreated
                )
            )
        }
    }

    func onClosePressed() {
        router.dismissEnvironment()
    }

}
