//
//  WorkoutModels.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import Foundation

enum TrackingMode: String, Codable, CaseIterable, Hashable {
    case weightReps
    case repsOnly
    case timeOnly
    case distanceTime
}

protocol WorkoutTemplateProviding {
    func fetchTemplates() -> [WorkoutTemplateModel]
}

struct LocalWorkoutTemplateService: WorkoutTemplateProviding {
    func fetchTemplates() -> [WorkoutTemplateModel] { WorkoutTemplateModel.mocks }
}
