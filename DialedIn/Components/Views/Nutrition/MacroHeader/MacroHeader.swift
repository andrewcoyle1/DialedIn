//
//  MacroHeader.swift
//  DialedIn
//
//  Created by Andrew Coyle on 12/03/2026.
//

import SwiftUI

struct MacroHeader: View {
    
    var caloriePercentage: Double
    var fatPercentage: Double
    var proteinPercentage: Double
    var carbsPercentage: Double

    let ringSize: CGFloat = 75
    
    var body: some View {
        HStack {
            ForEach(Macro.allCases, id: \.self) { macro in
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
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    List {
        MacroHeader(
            caloriePercentage: 0.5,
            fatPercentage: 0.4,
            proteinPercentage: 0.3,
            carbsPercentage: 0.2
        )
    }
}
