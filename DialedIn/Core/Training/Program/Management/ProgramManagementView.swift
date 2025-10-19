//
//  ProgramManagementView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    @Environment(ProgramTemplateManager.self) private var programTemplateManager
    @Environment(AuthManager.self) private var authManager
    
    @State private var showCreateSheet = false
    @State private var editingPlan: TrainingPlan?
    @State private var planToDelete: TrainingPlan?
    @State private var showDeleteAlert = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            List {
                if !trainingPlanManager.allPlans.isEmpty {
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
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                ProgramTemplatePickerView()
            }
            .sheet(item: $editingPlan) { plan in
                EditProgramView(plan: plan)
            }
            .alert("Delete Program", isPresented: $showDeleteAlert, presenting: planToDelete) { plan in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await deletePlan(plan)
                    }
                }
            } message: { plan in
                if plan.isActive {
                    Text("Are you sure you want to delete your active program '\(plan.name)'? This will remove all scheduled workouts and you'll need to create or select a new program.")
                } else {
                    Text("Are you sure you want to delete '\(plan.name)'? This action cannot be undone.")
                }
            }
            .overlay {
                if isLoading {
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
            if let activePlan = trainingPlanManager.currentTrainingPlan {
                Section {
                    ProgramRow(
                        plan: activePlan,
                        isActive: true,
                        onActivate: {},
                        onEdit: { editingPlan = activePlan },
                        onDelete: {
                            planToDelete = activePlan
                            showDeleteAlert = true
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
            let inactivePlans = trainingPlanManager.allPlans.filter { !$0.isActive }
            
            if !inactivePlans.isEmpty {
                Section {
                    ForEach(inactivePlans) { plan in
                        ProgramRow(
                            plan: plan,
                            isActive: false,
                            onActivate: {
                                Task {
                                    await setActivePlan(plan)
                                }
                            },
                            onEdit: { editingPlan = plan },
                            onDelete: {
                                planToDelete = plan
                                showDeleteAlert = true
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
                showCreateSheet = true
            } label: {
                Text("Create Program")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func setActivePlan(_ plan: TrainingPlan) async {
        isLoading = true
        defer { isLoading = false }
        
        trainingPlanManager.setActivePlan(plan)
    }
    
    private func deletePlan(_ plan: TrainingPlan) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await trainingPlanManager.deletePlan(id: plan.planId)
        } catch {
            print("Error deleting plan: \(error)")
        }
    }
}

#Preview {
    ProgramManagementView()
        .previewEnvironment()
}
