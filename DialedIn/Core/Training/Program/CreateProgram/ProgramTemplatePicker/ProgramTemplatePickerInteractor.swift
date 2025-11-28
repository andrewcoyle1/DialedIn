//
//  ProgramTemplatePickerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

protocol ProgramTemplatePickerInteractor {
    var auth: UserAuthInfo? { get }
    func getBuiltInTemplates() -> [ProgramTemplateModel]
    func isBuiltIn(_ template: ProgramTemplateModel) -> Bool
    func createPlanFromTemplate(
        _ template: ProgramTemplateModel,
        startDate: Date,
        endDate: Date?,
        userId: String,
        planName: String?
    ) async throws -> TrainingPlan
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProgramTemplatePickerInteractor { }
