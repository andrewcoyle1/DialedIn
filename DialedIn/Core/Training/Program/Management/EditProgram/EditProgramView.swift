//
//  EditProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct EditProgramView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: EditProgramViewModel
    
    let plan: TrainingPlan
    
    init(viewModel: EditProgramViewModel, plan: TrainingPlan) {
        self.viewModel = viewModel
        self.plan = plan
        self.viewModel.originalStartDate = plan.startDate
        self.viewModel.name = plan.name
        self.viewModel.description = plan.description ?? ""
        self.viewModel.startDate = plan.startDate
        self.viewModel.endDate = plan.endDate
        self.viewModel.hasEndDate = plan.endDate != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Program Name", text: $viewModel.name)
                    
                    TextField("Description (Optional)", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Basic Information")
                }
                
                Section {
                    DatePicker("Start Date", selection: Binding(
                        get: { viewModel.startDate },
                        set: { newDate in
                            if !plan.weeks.flatMap({ $0.scheduledWorkouts }).isEmpty && newDate != viewModel.originalStartDate {
                                viewModel.pendingStartDate = newDate
                                viewModel.showDateChangeAlert = true
                            } else {
                                viewModel.startDate = newDate
                            }
                        }
                    ), displayedComponents: .date)
                    
                    Toggle("Set End Date", isOn: $viewModel.hasEndDate)
                    
                    if viewModel.hasEndDate {
                        DatePicker("End Date", selection: Binding(
                            get: { viewModel.endDate ?? viewModel.startDate },
                            set: { viewModel.endDate = $0 }
                        ), displayedComponents: .date)
                    }
                } header: {
                    Text("Schedule")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        if !viewModel.hasEndDate {
                            Text("Program will continue indefinitely")
                        }
                        if viewModel.startDate != viewModel.originalStartDate {
                            Text("Changing the start date will automatically reschedule all workouts")
                                .foregroundStyle(.orange)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Duration")
                        Spacer()
                        if viewModel.hasEndDate, let end = viewModel.endDate {
                            Text("\(viewModel.calculateWeeks(from: viewModel.startDate, to: end)) weeks")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Ongoing")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Scheduled Weeks")
                        Spacer()
                        Text("\(plan.weeks.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Total Workouts")
                        Spacer()
                        Text("\(viewModel.totalWorkouts(for: plan))")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Completed")
                        Spacer()
                        Text("\(viewModel.completedWorkouts(for: plan))")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Statistics")
                } footer: {
                    if viewModel.hasEndDate, let end = viewModel.endDate, viewModel.startDate != viewModel.originalStartDate || end != plan.endDate {
                        Text("Program duration will be adjusted based on new dates")
                            .foregroundStyle(.blue)
                    }
                }
                
                Section {
                    NavigationLink {
                        ProgramGoalsView(viewModel: ProgramGoalsViewModel(interactor: CoreInteractor(container: container), plan: plan))
                    } label: {
                        HStack {
                            Label("Manage Goals", systemImage: "target")
                            Spacer()
                            Text("\(plan.goals.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    NavigationLink {
                        ProgramScheduleView(
                            viewModel: ProgramScheduleViewModel(
                                interactor: CoreInteractor(
                                    container: container
                                )
                            ),
                            plan: plan
                        )
                    } label: {
                        Label("View Schedule", systemImage: "calendar")
                    }
                } header: {
                    Text("Details")
                }
                
                if plan.isActive {
                    Section {
                        Button(role: .destructive) {
                            viewModel.showDeleteActiveAlert = true
                        } label: {
                            Label("Delete Program", systemImage: "trash")
                        }
                    } footer: {
                        Text("This is your active program. Deleting it will remove all scheduled workouts and progress tracking.")
                    }
                }
            }
            .navigationTitle("Edit Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.savePlan(plan: plan, onDismiss: {
                                dismiss()
                            })
                        }
                    }
                    .disabled(viewModel.name.isEmpty || viewModel.isSaving)
                }
            }
            .overlay {
                if viewModel.isSaving {
                    ProgressView()
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .alert("Reschedule Workouts", isPresented: $viewModel.showDateChangeAlert) {
                Button("Cancel", role: .cancel) {
                    viewModel.pendingStartDate = nil
                }
                Button("Reschedule") {
                    if let newDate = viewModel.pendingStartDate {
                        viewModel.startDate = newDate
                        viewModel.pendingStartDate = nil
                    }
                }
            } message: {
                Text("This program has scheduled workouts. Changing the start date will automatically reschedule all workouts. Do you want to continue?")
            }
            .alert("Delete Active Program", isPresented: $viewModel.showDeleteActiveAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteActivePlan(plan: plan, onDismiss: {
                            dismiss()
                        })
                    }
                }
            } message: {
                Text("Are you sure you want to delete your active program '\(plan.name)'? This will remove all scheduled workouts and you'll need to create or select a new program.")
            }
        }
    }
}

#Preview {
    EditProgramView(viewModel: EditProgramViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), plan: TrainingPlan.mock)
        .previewEnvironment()
}
