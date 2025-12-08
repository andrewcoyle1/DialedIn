//
//  GoalRow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct GoalRowDelegate {
    let goal: TrainingGoal
    let plan: TrainingPlan
}

struct GoalRow: View {
    @State var presenter: GoalRowPresenter

    let delegate: GoalRowDelegate

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(delegate.goal.type.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(delegate.goal.progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: delegate.goal.progress)

            HStack {
                Text("\(Int(delegate.goal.currentValue)) / \(Int(delegate.goal.targetValue)) \(delegate.goal.type.unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if let targetDate = delegate.goal.targetDate {
                    Text(targetDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task {
                    await presenter.removeGoal(goal: delegate.goal)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

extension CoreBuilder {
    func goalRow(delegate: GoalRowDelegate) -> some View {
        GoalRow(
            presenter: GoalRowPresenter(interactor: interactor),
            delegate: delegate
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.goalRow(
        delegate: GoalRowDelegate(
            goal: TrainingGoal.mocks.first!,
            plan: TrainingPlan.mock
        )
    )
    .previewEnvironment()
}
