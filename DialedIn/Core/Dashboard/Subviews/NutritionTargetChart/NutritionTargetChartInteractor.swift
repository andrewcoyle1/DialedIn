//
//  NutritionTargetChartInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol NutritionTargetChartInteractor {
    var currentDietPlan: DietPlan? { get }
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget
}

extension CoreInteractor: NutritionTargetChartInteractor { }
