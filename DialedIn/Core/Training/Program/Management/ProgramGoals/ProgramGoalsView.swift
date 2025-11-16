//
//  ProgramGoalsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramGoalsView: View {

    @Environment(CoreBuilder.self) private var builder
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: ProgramGoalsViewModel

    var body: some View {
        List {
            if viewModel.plan.goals.isEmpty {
                ContentUnavailableView(
                    "No Goals",
                    systemImage: "target",
                    description: Text("Add goals to track your progress")
                )
            } else {
                ForEach(viewModel.plan.goals) { goal in
                    builder.goalRow(delegate: GoalRowDelegate(goal: goal, plan: viewModel.plan))
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
            builder.addGoalView(delegate: AddGoalViewDelegate(plan: viewModel.plan))
        }
    }
}

#Preview {
    ProgramGoalsView(viewModel: ProgramGoalsViewModel(interactor: CoreInteractor(container: DevPreview.shared.container), plan: TrainingPlan.mock))
        .previewEnvironment()
}
