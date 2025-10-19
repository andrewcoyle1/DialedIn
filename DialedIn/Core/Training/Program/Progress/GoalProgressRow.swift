//
//  GoalProgressRow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct GoalProgressRow: View {
    let goal: TrainingGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.type.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: goal.progress) {
                HStack {
                    Text("\(Int(goal.currentValue)) / \(Int(goal.targetValue)) \(goal.type.unit)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let targetDate = goal.targetDate {
                        Text(targetDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    List {
        GoalProgressRow(goal: TrainingGoal.mocks.first!)
    }
}
