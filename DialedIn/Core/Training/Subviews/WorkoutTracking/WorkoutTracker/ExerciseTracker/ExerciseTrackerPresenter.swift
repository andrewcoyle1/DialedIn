//
//  ExerciseTrackerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/03/2026.
//

import SwiftUI

@Observable
@MainActor
class ExerciseTrackerPresenter {
    private let interactor: ExerciseTrackerInteractor
    private let router: ExerciseTrackerRouter
    
    init(
        interactor: ExerciseTrackerInteractor,
        router: ExerciseTrackerRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
}
