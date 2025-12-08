//
//  ProgramManagementView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ProgramManagementView: View {

    @State var presenter: ProgramManagementPresenter

    @ViewBuilder var programRowView: (ProgramRowDelegate) -> AnyView

    var body: some View {
        List {
            if !presenter.trainingPlans.isEmpty {
                activeProgramSection
                otherProgramsSection
            } else {
                emptyState
            }
        }
        .navigationTitle("My Programs")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .overlay {
            if presenter.isLoading {
                ProgressView()
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var activeProgramSection: some View {
        Group {
            if let activePlan = presenter.activePlan {
                Section {
                    let delegate = ProgramRowDelegate(
                        plan: activePlan,
                        isActive: true,
                        onEdit: { presenter.onEditPlanPressed(plan: activePlan) },
                        onDelete: {
                            presenter.planToDelete = activePlan
                            presenter.showDeleteAlert(activePlan: activePlan)
                        }
                    )
                    programRowView(delegate)
                } header: {
                    Text("Active Program")
                } footer: {
                    Text("This is your currently active training program.")
                }
            }
        }
    }
    
    private var otherProgramsSection: some View {
        Group {
            let inactivePlans = presenter.trainingPlans.filter { !$0.isActive }
            
            if !inactivePlans.isEmpty {
                Section {
                    ForEach(inactivePlans) { plan in
                        programRowView(
                            ProgramRowDelegate(
                                plan: plan,
                                isActive: false,
                                onActivate: {
                                    Task {
                                        await presenter.setActivePlan(plan)
                                    }
                                },
                                onEdit: { presenter.editingPlan = plan },
                                onDelete: {
                                    presenter.planToDelete = plan
                                    presenter.showDeleteAlert(activePlan: plan)
                                }
                            )
                        )
                    }
                } header: {
                    Text("Other Programs")
                }
            }
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Programs", systemImage: "calendar.badge.clock")
        } description: {
            Text("Create your first training program to get started")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                presenter.dismissScreen()
            } label: {
                Image(systemName: "xmark")
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                presenter.onCreateProgramPressed()
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

extension CoreBuilder {
    func programManagementView(router: AnyRouter) -> some View {
        ProgramManagementView(
            presenter: ProgramManagementPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            programRowView: { delegate in
                self.programRowView(delegate: delegate)
                    .any()
            }
        )
    }
}

extension CoreRouter {
    func showProgramManagementView() {
        router.showScreen(.fullScreenCover) { router in
            builder.programManagementView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.programManagementView(router: router)
    }
    .previewEnvironment()
}
