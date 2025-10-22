//
//  ProgramManagementView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramManagementView: View {
    @State var viewModel: ProgramManagementViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(DependencyContainer.self) private var container
    
    var body: some View {
        NavigationStack {
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
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
            .sheet(isPresented: $viewModel.showCreateSheet) {
                ProgramTemplatePickerView(viewModel: ProgramTemplatePickerViewModel(container: container))
            }
            .sheet(item: $viewModel.editingPlan) { plan in
                EditProgramView(viewModel: EditProgramViewModel(container: container), plan: plan)
            }
            .showCustomAlert(alert: $viewModel.showDeleteAlert)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    private var activeProgramSection: some View {
        Group {
            if let activePlan = viewModel.activePlan {
                Section {
                    ProgramRowView(
                        viewModel: ProgramRowViewModel(
                            container: container,
                            plan: activePlan,
                            isActive: true,
                            onActivate: {},
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
                    )
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
                        ProgramRowView(
                            viewModel: ProgramRowViewModel(
                                container: container,
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
}

#Preview {
    ProgramManagementView(viewModel: ProgramManagementViewModel(container: DevPreview.shared.container))
        .previewEnvironment()
}
