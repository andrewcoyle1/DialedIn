//
//  ProgramGoalsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ProgramGoalsView: View {

    @State var presenter: ProgramGoalsPresenter

    let delegate: ProgramGoalsDelegate

    @ViewBuilder var goalRow: (GoalRowDelegate) -> AnyView

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
                    presenter.onAddGoalPressed(plan: delegate.plan)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.programGoalsView(router: router, delegate: ProgramGoalsDelegate(plan: .mock))
    }
    .previewEnvironment()
}
