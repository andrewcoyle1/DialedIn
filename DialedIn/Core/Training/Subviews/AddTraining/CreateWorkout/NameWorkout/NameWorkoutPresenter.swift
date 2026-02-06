//
//  NameWorkoutPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI
import PhotosUI

@Observable
@MainActor
class NameWorkoutPresenter {
    
    private let interactor: NameWorkoutInteractor
    private let router: NameWorkoutRouter
    
    var workoutName: String = ""
    var isSaving: Bool = false
    var canSave: Bool {
        !workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(
        interactor: NameWorkoutInteractor,
        router: NameWorkoutRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
        
    func onContinuePressed() {
        router.showChooseGymProfileView(delegate: ChooseGymProfileDelegate(name: workoutName))
    }

}
