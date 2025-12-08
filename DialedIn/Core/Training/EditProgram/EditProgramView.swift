//
//  EditProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct EditProgramView: View {

    @State var presenter: EditProgramPresenter
    
    var delegate: EditProgramDelegate

    var body: some View {
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
        .onAppear {
            presenter.loadData(for: delegate.plan)
        }
        .overlay {
            if presenter.isSaving {
                ProgressView()
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var basicInfoSection: some View {
        Section {
            TextField("Program Name", text: $presenter.name)

            TextField("Description (Optional)", text: $presenter.description, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Basic Information")
        }
    }

    private var scheduleSection: some View {
        Section {
            DatePicker("Start Date", selection: Binding(
                get: { presenter.startDate },
                set: { newDate in
                    if !delegate.plan.weeks.flatMap({ $0.scheduledWorkouts }).isEmpty && newDate != presenter.originalStartDate {
                        presenter.pendingStartDate = newDate
                        presenter.showDateChangeAlert(startDate: $presenter.startDate)
                    } else {
                        presenter.startDate = newDate
                    }
                }
            ), displayedComponents: .date)

            Toggle("Set End Date", isOn: $presenter.hasEndDate)

            if presenter.hasEndDate {
                DatePicker("End Date", selection: Binding(
                    get: { presenter.endDate ?? presenter.startDate },
                    set: { presenter.endDate = $0 }
                ), displayedComponents: .date)
            }
        } header: {
            Text("Schedule")
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                if !presenter.hasEndDate {
                    Text("Program will continue indefinitely")
                }
                if presenter.startDate != presenter.originalStartDate {
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
                if presenter.hasEndDate, let end = presenter.endDate {
                    Text("\(presenter.calculateWeeks(from: presenter.startDate, to: end)) weeks")
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
                Text("\(presenter.totalWorkouts(for: delegate.plan))")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Completed")
                Spacer()
                Text("\(presenter.completedWorkouts(for: delegate.plan))")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Statistics")
        } footer: {
            if presenter.hasEndDate, let end = presenter.endDate, presenter.startDate != presenter.originalStartDate || end != delegate.plan.endDate {
                Text("Program duration will be adjusted based on new dates")
                    .foregroundStyle(.blue)
            }
        }
    }

    private var detailsSection: some View {
        Section {
            Button {
                presenter.navToProgramGoalsView(plan: delegate.plan)
            } label: {
                HStack {
                    Label("Manage Goals", systemImage: "target")
                    Spacer()
                    Text("\(delegate.plan.goals.count)")
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                presenter.navToProgramScheduleView(plan: delegate.plan)
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
                    presenter.showDeleteActiveAlert(plan: delegate.plan)
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
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                Task {
                    await presenter.savePlan(plan: delegate.plan, onDismiss: {
                        presenter.dismissScreen()
                    })
                }
            }
            .disabled(presenter.name.isEmpty || presenter.isSaving)
        }
    }
}

extension CoreBuilder {
    func editProgramView(router: AnyRouter, delegate: EditProgramDelegate) -> some View {
        EditProgramView(
            presenter: EditProgramPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showEditProgramView(delegate: EditProgramDelegate) {
        router.showScreen(.push) { router in
            builder.editProgramView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = EditProgramDelegate(
        plan: .mock
    )
    RouterView { router in
        builder.editProgramView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
