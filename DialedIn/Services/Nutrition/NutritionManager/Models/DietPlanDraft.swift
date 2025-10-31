//
//  DietPlanDraft.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import Foundation

struct DietPlanDraft: Equatable, Sendable {
    var preferredDiet: PreferredDiet?
    var calorieFloor: CalorieFloor?
    var trainingType: TrainingType?
    var calorieDistribution: CalorieDistribution?
    var proteinIntake: ProteinIntake?
}
