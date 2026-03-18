//
//  MacroHeader.swift
//  DialedIn
//
//  Created by Andrew Coyle on 12/03/2026.
//

import SwiftUI

struct MacroHeader: View {

    var dailyTotals: DailyMacroTarget
    var dailyTarget: DailyMacroTarget
    var showCaloriesRing: Bool = true
    var showProteinRing: Bool = true
    var showFatRing: Bool = true
    var showCarbsRing: Bool = true

    var caloriePercentage: Double {
        guard dailyTarget.calories > 0 else { return 0 }
        return (dailyTotals.calories) / dailyTarget.calories
    }

    var fatPercentage: Double {
        guard dailyTarget.fatGrams > 0 else { return 0 }
        return (dailyTotals.fatGrams) / dailyTarget.fatGrams
    }

    var proteinPercentage: Double {
        guard dailyTarget.proteinGrams > 0 else { return 0 }
        return (dailyTotals.proteinGrams) / dailyTarget.proteinGrams
    }

    var carbsPercentage: Double {
        guard dailyTarget.carbGrams > 0 else { return 0 }
        return (dailyTotals.carbGrams) / dailyTarget.carbGrams
    }

    let ringSize: CGFloat = 75

    var body: some View {
        HStack {
            ForEach(Macro.allCases, id: \.self) { macro in
                if shouldShow(macro) {
                    VStack {
                        ActivityRingView(
                            text: macro.title,
                            imageName: macro.iconName,
                            progress: {
                                switch macro {
                                case .cals: return caloriePercentage
                                case .fat: return fatPercentage
                                case .protein: return proteinPercentage
                                case .carbs: return carbsPercentage
                                }
                            }(),
                            color: macro.colour,
                            size: ringSize
                        )
                        Group {
                            switch macro {
                            case .cals: Text("\(Int(dailyTotals.calories))/\(Int(dailyTarget.calories))")
                            case .fat: Text("\(Int(dailyTotals.fatGrams))/\(Int(dailyTarget.fatGrams))g")
                            case .protein: Text("\(Int(dailyTotals.proteinGrams))/\(Int(dailyTarget.proteinGrams))g")
                            case .carbs: Text("\(Int(dailyTotals.carbGrams))/\(Int(dailyTarget.carbGrams))g")
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func shouldShow(_ macro: Macro) -> Bool {
        switch macro {
        case .cals: return showCaloriesRing
        case .protein: return showProteinRing
        case .fat: return showFatRing
        case .carbs: return showCarbsRing
        }
    }
}

#Preview {

    let totals = DailyMacroTarget(
        calories: 2000,
        proteinGrams: 140,
        carbGrams: 200,
        fatGrams: 50
    )
    let targets = DailyMacroTarget(
        calories: 2145,
        proteinGrams: 150,
        carbGrams: 242,
        fatGrams: 64
    )

    List {
        MacroHeader(
            dailyTotals: totals,
            dailyTarget: targets
        )
    }
}
