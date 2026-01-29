//
//  ProgramPreviewPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgramPreviewPresenter {
    private let interactor: ProgramPreviewInteractor
    private let router: ProgramPreviewRouter

    private(set) var previewPlan: TrainingPlan?
    private(set) var template: ProgramTemplateModel?
    private(set) var startDate: Date?
    
    var currentStartDate: Date {
        startDate ?? Date()
    }
    
    init(
        interactor: ProgramPreviewInteractor,
        router: ProgramPreviewRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func setTemplate(_ template: ProgramTemplateModel) {
        self.template = template
    }
    
    func setStartDate(_ startDate: Date) {
        self.startDate = startDate
    }
    
    func generatePreview() {
        guard let userId = interactor.auth?.uid else { return }
        guard let template else { return }
        previewPlan = interactor.instantiateTemplate(
            template,
            for: userId,
            startDate: currentStartDate,
            endDate: nil,
            planName: nil
        )
    }
    
    func dayOfWeekName(for date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
