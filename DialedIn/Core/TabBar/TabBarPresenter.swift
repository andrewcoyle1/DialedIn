//
//  TabBarPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class TabBarPresenter {
    
    private let interactor: TabBarInteractor

    var activeSession: WorkoutSessionModel? {
        interactor.activeSession
    }

    init(
        interactor: TabBarInteractor
    ) {
        self.interactor = interactor
    }
}
