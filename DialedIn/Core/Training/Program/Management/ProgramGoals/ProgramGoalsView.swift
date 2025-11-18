//
//  ProgramGoalsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramGoalsViewDelegate {
    let plan: TrainingPlan
}

struct ProgramGoalsView: View {

    @Environment(\.dismiss) private var dismiss

    @State var viewModel: ProgramGoalsViewModel

    let delegate: ProgramGoalsViewDelegate

    @ViewBuilder var goalRow: (GoalRowDelegate) -> AnyView
    @ViewBuilder var addGoalView: (AddGoalViewDelegate) -> AnyView

    var body: some View {
        List {
            if delegate.plan.goals.isEmpty {
                ContentUnavailableView(
                    "No Goals",
                    systemImage: "target",
                    description: Text("Add goals to track your progress")
                )
            } else {
                ForEach(delegate.plan.goals) { goal in
                    goalRow(GoalRowDelegate(goal: goal, plan: delegate.plan))
                }
            }
        }
        .navigationTitle("Goals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showAddGoal = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddGoal) {
            addGoalView(AddGoalViewDelegate(plan: delegate.plan))
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.programGoalsView(delegate: ProgramGoalsViewDelegate(plan: .mock))
        .previewEnvironment()
}
