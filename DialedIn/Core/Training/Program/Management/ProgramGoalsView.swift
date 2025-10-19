//
//  ProgramGoalsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramGoalsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    
    let plan: TrainingPlan
    
    @State private var showAddGoal = false
    
    var body: some View {
        List {
            if plan.goals.isEmpty {
                ContentUnavailableView(
                    "No Goals",
                    systemImage: "target",
                    description: Text("Add goals to track your progress")
                )
            } else {
                ForEach(plan.goals) { goal in
                    GoalRow(goal: goal, plan: plan)
                }
            }
        }
        .navigationTitle("Goals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddGoal = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddGoal) {
            AddGoalView(plan: plan)
        }
    }
}

#Preview {
    ProgramGoalsView(plan: TrainingPlan.mock)
        .previewEnvironment()
}
