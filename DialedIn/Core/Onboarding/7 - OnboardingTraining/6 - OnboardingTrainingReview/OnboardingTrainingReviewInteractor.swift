//
//  OnboardingTrainingReviewInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

protocol OnboardingTrainingReviewInteractor {
    var currentUser: UserModel? { get }
    func getBuiltInTemplates() -> [ProgramTemplateModel]
    func createPlanFromTemplate(
        _ template: ProgramTemplateModel,
        startDate: Date,
        endDate: Date?,
        userId: String,
        planName: String?
    ) async throws -> TrainingPlan
    func setActivePlan(_ plan: TrainingPlan)
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingTrainingReviewInteractor { }
