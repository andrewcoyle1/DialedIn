//
//  DietPlanBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import Foundation

struct DietPlanBuilder: Sendable, Hashable {
    var preferredDiet: PreferredDiet
    var calorieFloor: CalorieFloor?
    var trainingType: TrainingType?
    var calorieDistribution: CalorieDistribution?
    var proteinIntake: ProteinIntake?

    var eventParameters: [String: Any] {
        let params = [
            "preferredDiet": self.preferredDiet.description as Any,
            "calorieFloor": self.calorieFloor?.description as Any,
            "trainingType": self.trainingType?.description as Any,
            "calorieDistribution": self.calorieDistribution?.description as Any,
            "proteinIntake": self.proteinIntake?.description as Any
        ]

        return params
    }

    mutating func setCalorieFloor(_ calorieFloor: CalorieFloor) {
        self.calorieFloor = calorieFloor
    }

    mutating func setTrainingType(_ trainingType: TrainingType) {
        self.trainingType = trainingType
    }

    mutating func setCalorieDistribution(_ calorieDistribution: CalorieDistribution) {
        self.calorieDistribution = calorieDistribution
    }

    mutating func setProteinIntake(_ proteinIntake: ProteinIntake) {
        self.proteinIntake = proteinIntake
    }

    static var CalorieFloorMock: DietPlanBuilder {
        DietPlanBuilder(
            preferredDiet: .balanced
        )
    }

    static var trainingTypeMock: DietPlanBuilder {
        DietPlanBuilder(
            preferredDiet: .balanced,
            calorieFloor: .standard
        )
    }

    static var calorieDistributionMock: DietPlanBuilder {
        DietPlanBuilder(
            preferredDiet: .balanced,
            calorieFloor: .standard,
            trainingType: .cardioAndWeightlifting
        )
    }

    static var proteinIntakeMock: DietPlanBuilder {
        DietPlanBuilder(
            preferredDiet: .balanced,
            calorieFloor: .standard,
            trainingType: .cardioAndWeightlifting,
            calorieDistribution: .even
        )
    }

    static var mock: DietPlanBuilder {
        DietPlanBuilder(
            preferredDiet: .balanced,
            calorieFloor: .standard,
            trainingType: .cardioAndWeightlifting,
            calorieDistribution: .even,
            proteinIntake: .moderate
        )
    }
}
