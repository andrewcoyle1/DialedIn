//
//  CopyWeekPickerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

import Foundation

@Observable
@MainActor
class CopyWeekPickerPresenter {
    private let interactor: CopyWeekPickerInteractor
    private let router: CopyWeekPickerRouter

    init(
        interactor: CopyWeekPickerInteractor,
        router: CopyWeekPickerRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
}
