//
//  ManageSubscriptionPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@Observable
@MainActor
class ManageSubscriptionPresenter {
    private let interactor: ManageSubscriptionInteractor
    private let router: ManageSubscriptionRouter

    var isPremium: Bool = false
    var selectedPlan: PlanOption = .annual
    private(set) var isLoading: Bool = false
    private(set) var showLegalDisclaimer: Bool = true

    init(
        interactor: ManageSubscriptionInteractor,
        router: ManageSubscriptionRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func onDismiss() {
        router.dismissScreen()
    }
}
