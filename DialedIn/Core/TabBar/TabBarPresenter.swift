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
    private let router: TabBarRouter

    var activeSession: WorkoutSessionModel? {
        interactor.activeSession
    }
    
    var draftMeal: MealLogModel? {
        interactor.draftMeal
    }
    
    var showTabAccessory: Bool {
        activeSession != nil || draftMeal != nil
    }
    
    var tabAccessoryWidth: CGFloat = 400

    init(
        interactor: TabBarInteractor,
        router: TabBarRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
}
