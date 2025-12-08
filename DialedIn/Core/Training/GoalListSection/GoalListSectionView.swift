//
//  GoalListSectionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

import SwiftUI
import SwiftfulRouting

struct GoalListSectionView: View {
    
    @State var presenter: GoalListSectionPresenter
    
    var body: some View {
        Group {
            if let plan = presenter.currentTrainingPlan {
                Section(isExpanded: $presenter.isExpanded) {
                    if !plan.goals.isEmpty {
                        ForEach(plan.goals) { goal in
                            GoalProgressRow(goal: goal)
                        }
                    } else {
                        ContentUnavailableView {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                        } description: {
                            Text("No training goals set. Tap the plus button to add one.")
                        } actions: {
                            Button {
                                if presenter.currentTrainingPlan != nil {
                                    presenter.onAddGoalPressed()
                                }
                            } label: {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } header: {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Goals")
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(presenter.isExpanded ? 0 : 90))
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        presenter.onExpansionToggled()
                    }
                    .animation(.easeInOut, value: presenter.isExpanded)
                }
            }
        }
    }
}

extension CoreBuilder {
    func goalListSectionView(router: AnyRouter) -> some View {
        GoalListSectionView(
            presenter: GoalListSectionPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    
    RouterView { router in
        List {
            builder.goalListSectionView(router: router)
        }
    }
}
