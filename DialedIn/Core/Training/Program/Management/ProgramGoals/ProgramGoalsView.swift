//
//  ProgramGoalsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramGoalsView: View {
    @State var viewModel: ProgramGoalsViewModel
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
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
                    GoalRow(viewModel: GoalRowViewModel(container: container, goal: goal, plan: viewModel.plan))
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
            AddGoalView(viewModel: AddGoalViewModel(container: container), plan: viewModel.plan)
        }
    }
}

#Preview {
    ProgramGoalsView(viewModel: ProgramGoalsViewModel(container: DevPreview.shared.container, plan: TrainingPlan.mock))
        .previewEnvironment()
}
