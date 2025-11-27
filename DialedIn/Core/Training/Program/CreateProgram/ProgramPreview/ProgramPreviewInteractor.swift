//
//  ProgramPreviewInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

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
