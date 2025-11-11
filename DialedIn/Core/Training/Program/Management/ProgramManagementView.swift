//
//  ProgramManagementView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramManagementView: View {
    @Environment(CoreBuilder.self) private var builder
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: ProgramManagementViewModel

    @Binding var path: [TabBarPathOption]

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
                builder.programTemplatePickerView(path: $path)
            }
            .sheet(item: $viewModel.editingPlan) { plan in
                builder.editProgramView(path: $path, plan: plan)
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
                    builder.programRowView(
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
                        builder.programRowView(
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
    @Previewable @State var path: [TabBarPathOption] = []
    ProgramManagementView(
        viewModel: ProgramManagementViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        ),
        path: $path
    )
    .previewEnvironment()
}
