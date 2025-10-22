//
//  GoalRow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct GoalRow: View {
    @State var viewModel: GoalRowViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(viewModel.goal.type.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(viewModel.goal.progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: viewModel.goal.progress)
            
            HStack {
                Text("\(Int(viewModel.goal.currentValue)) / \(Int(viewModel.goal.targetValue)) \(viewModel.goal.type.unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if let targetDate = viewModel.goal.targetDate {
                    Text(targetDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task {
                    await viewModel.removeGoal()
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    GoalRow(
        viewModel: GoalRowViewModel(
            container: DevPreview.shared.container,
            goal: TrainingGoal.mocks.first!,
            plan: TrainingPlan.mock
        )
    )
    .previewEnvironment()
}
