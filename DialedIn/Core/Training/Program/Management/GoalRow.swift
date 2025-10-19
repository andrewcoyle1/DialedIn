//
//  GoalRow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct GoalRow: View {
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    let goal: TrainingGoal
    let plan: TrainingPlan
    
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
            
            ProgressView(value: goal.progress)
            
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
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task {
                    try? await trainingPlanManager.removeGoal(id: goal.id)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    GoalRow(goal: TrainingGoal.mocks.first!, plan: TrainingPlan.mock)
        .previewEnvironment()
}
