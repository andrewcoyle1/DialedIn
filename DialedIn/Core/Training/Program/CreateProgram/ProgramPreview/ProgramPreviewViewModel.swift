//
//  ProgramPreviewViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProgramPreviewInteractor {
    var auth: UserAuthInfo? { get }
    func instantiateTemplate(
        _ template: ProgramTemplateModel,
        for userId: String,
        startDate: Date,
        endDate: Date?,
        planName: String?
    ) -> TrainingPlan
}

extension CoreInteractor: ProgramPreviewInteractor { }

@Observable
@MainActor
class ProgramPreviewViewModel {
    private let interactor: ProgramPreviewInteractor
    
    private(set) var previewPlan: TrainingPlan?
    private(set) var template: ProgramTemplateModel?
    private(set) var startDate: Date?
    
    var currentStartDate: Date {
        startDate ?? Date()
    }
    
    init(
        interactor: ProgramPreviewInteractor
    ) {
        self.interactor = interactor
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
}
