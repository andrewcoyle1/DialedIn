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
    
    @Binding var path: [TabBarPathOption]

    let plan: TrainingPlan

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                scheduleSection
                statisticsSection
                detailsSection
                deletePlanSection()
            }
            .navigationTitle("Edit Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .overlay {
                if viewModel.isSaving {
                    ProgressView()
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .showCustomAlert(alert: $viewModel.showAlert)
        }
    }

    private var basicInfoSection: some View {
        Section {
            TextField("Program Name", text: $viewModel.name)

            TextField("Description (Optional)", text: $viewModel.description, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Basic Information")
        }
    }

    private var scheduleSection: some View {
        Section {
            DatePicker("Start Date", selection: Binding(
                get: { viewModel.startDate },
                set: { newDate in
                    if !plan.weeks.flatMap({ $0.scheduledWorkouts }).isEmpty && newDate != viewModel.originalStartDate {
                        viewModel.pendingStartDate = newDate
                        viewModel.showDateChangeAlert(startDate: $viewModel.startDate)
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
    }

    private var statisticsSection: some View {
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
    }

    private var detailsSection: some View {
        Section {
            Button {
                viewModel.navToProgramGoalsView(path: $path, plan: plan)
            } label: {
                HStack {
                    Label("Manage Goals", systemImage: "target")
                    Spacer()
                    Text("\(plan.goals.count)")
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                viewModel.navToProgramScheduleView(path: $path, plan: plan)
            } label: {
                Label("View Schedule", systemImage: "calendar")
            }
        } header: {
            Text("Details")
        }
    }

    @ViewBuilder
    func deletePlanSection() -> some View {
        if plan.isActive {
            Section {
                Button(role: .destructive) {
                    viewModel.showDeleteActiveAlert(plan: plan, onDismiss: { dismiss() })
                } label: {
                    Label("Delete Program", systemImage: "trash")
                }
            } footer: {
                Text("This is your active program. Deleting it will remove all scheduled workouts and progress tracking.")
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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
}

#Preview {
    @Previewable @State var path: [TabBarPathOption] = []
    EditProgramView(
        viewModel: EditProgramViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            plan: TrainingPlan.mock
        ),
        path: $path,
        plan: TrainingPlan.mock
    )
    .previewEnvironment()
}
