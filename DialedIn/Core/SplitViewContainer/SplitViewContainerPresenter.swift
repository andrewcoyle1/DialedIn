//
//  SplitViewContainerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/11/2025.
//

import SwiftUI

@Observable
@MainActor
class SplitViewContainerPresenter {
    private let interactor: SplitViewContainerInteractor
    
    var preferredColumn: NavigationSplitViewColumn = .sidebar

    var activeSession: WorkoutSessionModel? {
        interactor.activeSession
    }
    
    init(interactor: SplitViewContainerInteractor) {
        self.interactor = interactor
    }
}
