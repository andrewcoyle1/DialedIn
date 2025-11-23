//
//  EditProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import CustomRouting

struct EditProgramViewDelegate {
    var plan: TrainingPlan
}

struct EditProgramView: View {

    @State var viewModel: EditProgramViewModel
    
    var delegate: EditProgramViewDelegate

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
                    if !delegate.plan.weeks.flatMap({ $0.scheduledWorkouts }).isEmpty && newDate != viewModel.originalStartDate {
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
                Text("\(delegate.plan.weeks.count)")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Total Workouts")
                Spacer()
                Text("\(viewModel.totalWorkouts(for: delegate.plan))")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Completed")
                Spacer()
                Text("\(viewModel.completedWorkouts(for: delegate.plan))")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Statistics")
        } footer: {
            if viewModel.hasEndDate, let end = viewModel.endDate, viewModel.startDate != viewModel.originalStartDate || end != delegate.plan.endDate {
                Text("Program duration will be adjusted based on new dates")
                    .foregroundStyle(.blue)
            }
        }
    }

    private var detailsSection: some View {
        Section {
            Button {
                viewModel.navToProgramGoalsView(plan: delegate.plan)
            } label: {
                HStack {
                    Label("Manage Goals", systemImage: "target")
                    Spacer()
                    Text("\(delegate.plan.goals.count)")
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                viewModel.navToProgramScheduleView(plan: delegate.plan)
            } label: {
                Label("View Schedule", systemImage: "calendar")
            }
        } header: {
            Text("Details")
        }
    }

    @ViewBuilder
    func deletePlanSection() -> some View {
        if delegate.plan.isActive {
            Section {
                Button(role: .destructive) {
                    viewModel.showDeleteActiveAlert(plan: delegate.plan)
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
                viewModel.dismissScreen()            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                Task {
                    await viewModel.savePlan(plan: delegate.plan, onDismiss: {
                        viewModel.dismissScreen()
                    })
                }
            }
            .disabled(viewModel.name.isEmpty || viewModel.isSaving)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = EditProgramViewDelegate(
        plan: .mock
    )
    RouterView { router in
        builder.editProgramView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
