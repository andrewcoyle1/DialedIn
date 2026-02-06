//
//  CreateWorkoutPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI
import PhotosUI

@Observable
@MainActor
class CreateWorkoutPresenter {
    
    private let interactor: CreateWorkoutInteractor
    private let router: CreateWorkoutRouter
    
    init(
        interactor: CreateWorkoutInteractor,
        router: CreateWorkoutRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onContinuePressed() {
        router.showNameWorkoutView(delegate: NameWorkoutDelegate())
    }
    
    func cancel() {
        router.dismissScreen()
    }

}
