//
//  CustomProgramBuilderInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol CustomProgramBuilderInteractor {
    var auth: UserAuthInfo? { get }
    func create(_ template: ProgramTemplateModel) async throws
    func createPlanFromTemplate(
        _ template: ProgramTemplateModel,
        startDate: Date,
        endDate: Date?,
        userId: String,
        planName: String?
    ) async throws -> TrainingPlan
}

extension CoreInteractor: CustomProgramBuilderInteractor { }
