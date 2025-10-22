//
//  ProgramPreviewViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgramPreviewViewModel {
    private let authManager: AuthManager
    private let programTemplateManager: ProgramTemplateManager
    
    private(set) var previewPlan: TrainingPlan?
    private(set) var template: ProgramTemplateModel?
    private(set) var startDate: Date?
    
    var currentStartDate: Date {
        startDate ?? Date()
    }
    
    init(
        container: DependencyContainer
    ) {
        self.authManager = container.resolve(AuthManager.self)!
        self.programTemplateManager = container.resolve(ProgramTemplateManager.self)!
    }
    
    func setTemplate(_ template: ProgramTemplateModel) {
        self.template = template
    }
    
    func setStartDate(_ startDate: Date) {
        self.startDate = startDate
    }
    
    func generatePreview() {
        guard let userId = authManager.auth?.uid else { return }
        guard let template else { return }
        previewPlan = programTemplateManager.instantiateTemplate(
            template,
            for: userId,
            startDate: currentStartDate,
            planName: nil
        )
    }
    
    func dayOfWeekName(for date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide))
    }
}
