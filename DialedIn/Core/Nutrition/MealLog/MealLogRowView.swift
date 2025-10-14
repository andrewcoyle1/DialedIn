//
//  MealLogRowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct MealLogRowView: View {
    let meal: MealLogModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(meal.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if let notes = meal.notes, !notes.isEmpty {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if !meal.items.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(meal.items.prefix(3)) { item in
                        HStack {
                            Text("• \(item.displayName)")
                                .font(.subheadline)
                            Spacer()
                            Text("\(Int(item.amount))\(item.unit)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if meal.items.count > 3 {
                        Text("+\(meal.items.count - 3) more items")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 12)
                    }
                }
            }
            
            Divider()
            
            HStack(spacing: 16) {
                MacroLabel(title: "Cal", value: Int(meal.totalCalories))
                MacroLabel(title: "P", value: Int(meal.totalProteinGrams))
                MacroLabel(title: "C", value: Int(meal.totalCarbGrams))
                MacroLabel(title: "F", value: Int(meal.totalFatGrams))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MealLogRowView(meal: MealLogModel.mock)
}
