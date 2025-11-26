//
//  ProgramManagementView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import CustomRouting

struct ProgramManagementView: View {

    @State var viewModel: ProgramManagementViewModel

    @ViewBuilder var programRowView: (ProgramRowViewDelegate) -> AnyView

    var body: some View {
        List {
            if !viewModel.trainingPlans.isEmpty {
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
            if viewModel.isLoading {
                ProgressView()
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var activeProgramSection: some View {
        Group {
            if let activePlan = viewModel.activePlan {
                Section {
                    let delegate = ProgramRowViewDelegate(
                        plan: activePlan,
                        isActive: true,
                        onEdit: { viewModel.editingPlan = activePlan },
                        onDelete: {
                            viewModel.planToDelete = activePlan
                            viewModel.showDeleteAlert = AnyAppAlert(
                                title: "Delete Program",
                                subtitle: "Are you sure you want to delete your active program '\(activePlan.name)'? This will remove all scheduled workouts and you'll need to create or select a new program.",
                                buttons: {
                                    AnyView(
                                        Group {
                                            Button("Cancel", role: .cancel) { }
                                            Button("Delete", role: .destructive) {
                                                Task {
                                                    await viewModel.deletePlan(activePlan)
                                                }
                                            }
                                        }
                                    )
                                }
                            )
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
            let inactivePlans = viewModel.trainingPlans.filter { !$0.isActive }
            
            if !inactivePlans.isEmpty {
                Section {
                    ForEach(inactivePlans) { plan in
                        programRowView(
                            ProgramRowViewDelegate(
                                plan: plan,
                                isActive: false,
                                onActivate: {
                                    Task {
                                        await viewModel.setActivePlan(plan)
                                    }
                                },
                                onEdit: { viewModel.editingPlan = plan },
                                onDelete: {
                                    viewModel.planToDelete = plan
                                    viewModel.showDeleteAlert = AnyAppAlert(
                                        title: "Delete Program",
                                        subtitle: "Are you sure you want to delete '\(plan.name)'? This action cannot be undone.",
                                        buttons: {
                                            AnyView(
                                                Group {
                                                    Button("Cancel", role: .cancel) { }
                                                    Button("Delete", role: .destructive) {
                                                        Task {
                                                            await viewModel.deletePlan(plan)
                                                        }
                                                    }
                                                }
                                            )
                                        }
                                    )
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
        } actions: {
            Button {
                viewModel.showCreateSheet = true
            } label: {
                Text("Create Program")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Done") {
                viewModel.dismissScreen()
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.showCreateSheet = true
            } label: {
                Image(systemName: "plus")
            }
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
