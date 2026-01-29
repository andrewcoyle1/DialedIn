//
//  TrainingProgressChartsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

import SwiftUI

@Observable
@MainActor
class TrainingProgressChartsPresenter {
    private let interactor: TrainingProgressChartsInteractor
    private let router: TrainingProgressChartsRouter
    
    var isExpanded: Bool = false
    
    init(
        interactor: TrainingProgressChartsInteractor,
        router: TrainingProgressChartsRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onExpandedToggle() {
        withAnimation {
            isExpanded.toggle()
        }
    }
    
    func onProgressAnalyticsPressed() {
        router.showProgressDashboardView()
    }
}
