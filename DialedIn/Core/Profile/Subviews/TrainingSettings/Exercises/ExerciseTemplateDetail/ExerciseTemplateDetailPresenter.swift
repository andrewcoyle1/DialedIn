//
//  ExerciseModelDetailPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ExerciseModelDetailPresenter {
    private let interactor: ExerciseModelDetailInteractor
    private let router: ExerciseModelDetailRouter

    var section: CustomSection = .description

    var isBookmarked: Bool = false
    var isFavourited: Bool = false
    private(set) var unitPreference: ExerciseUnitPreference?

    init(
        interactor: ExerciseModelDetailInteractor,
        router: ExerciseModelDetailRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var performedSubtitle: String {
        "No history yet"
    }
        
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}

enum CustomSection: Hashable {
    case description
    case history
    case charts
    case records
}
