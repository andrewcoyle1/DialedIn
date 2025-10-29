//
//  CustomProgramBuilderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct CustomProgramBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: CustomProgramBuilderViewModel
    
    var body: some View {
        List {
            detailsSection
            focusAreasSection
            scheduleSection
        }
        .navigationTitle("Custom Program")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showingWorkoutPicker) {
            if let day = viewModel.editingDayOfWeek {
                NavigationStack {
                    WorkoutPickerSheet(
                        interactor: CoreInteractor(
                            container: container
                        ),
                        onSelect: { workout in
                            viewModel.assign(
                                workout: workout,
                                to: day,
                                inWeek: viewModel.selectedWeek
                            )
                            viewModel.showingWorkoutPicker = false
                            viewModel.editingDayOfWeek = nil
                        },
                        onCancel: {
                            viewModel.showingWorkoutPicker = false
                            viewModel.editingDayOfWeek = nil
                        }
                    )
                }
            }
        }
        .sheet(item: $viewModel.startConfigTemplate) { template in
            ProgramStartConfigView(viewModel: ProgramStartConfigViewModel(interactor: CoreInteractor(container: container)), template: template) { startDate, endDate, customName in
                Task { await viewModel.startProgram(template: template, startDate: startDate, endDate: endDate, customName: customName, onDismiss: { dismiss() }) }
            }
        }
        .onChange(of: viewModel.durationWeeks) { _, newValue in
            viewModel.resizeWeeks(to: newValue)
        }
        .onAppear {
            viewModel.resizeWeeks(to: viewModel.durationWeeks)
        }
        .showCustomAlert(alert: $viewModel.showAlert)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Menu {
                Button {
                    Task { await viewModel.saveTemplate(onDismiss: { dismiss() }) }
                } label: { Label("Save", systemImage: "square.and.arrow.down") }
                
                Button {
                    guard let template = viewModel.buildTemplate() else { return }
                    viewModel.startConfigTemplate = template
                } label: { Label("Start…", systemImage: "play.circle.fill") }
                    .disabled(!viewModel.canContinue)
            } label: {
                if viewModel.isSaving || viewModel.isStarting {
                    ProgressView()
                } else {
                    Text("Actions")
                }
            }
        }
    }
    
    private var detailsSection: some View {
        Section("Details") {
            TextField("Program name", text: $viewModel.name)
            TextField("Description (optional)", text: $viewModel.descriptionText, axis: .vertical)
                .lineLimit(1...4)
            Stepper(value: $viewModel.durationWeeks, in: 1...52) {
                HStack {
                    Text("Duration")
                    Spacer()
                    Text("\(viewModel.durationWeeks) week\(viewModel.durationWeeks == 1 ? "" : "s")")
                        .foregroundStyle(.secondary)
                }
            }
            Picker("Difficulty", selection: $viewModel.difficulty) {
                ForEach(DifficultyLevel.allCases, id: \.self) { level in
                    HStack {
                        Image(systemName: level.systemImage)
                        Text(level.description)
                    }
                    .tag(level)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var focusAreasSection: some View {
        Section("Focus Areas") {
            VStack(alignment: .leading, spacing: 12) {
                WrappingChips(
                    items: FocusArea.allCases,
                    isSelected: { viewModel.selectedFocusAreas.contains($0) },
                    toggle: { area in
                        if viewModel.selectedFocusAreas.contains(area) {
                            viewModel.selectedFocusAreas.remove(area)
                        } else {
                            viewModel.selectedFocusAreas.insert(area)
                        }
                    },
                    label: { area in
                        HStack(spacing: 6) {
                            Image(systemName: area.systemImage)
                            Text(area.description)
                        }
                    }
                )
                .padding(.vertical, 4)
                
                if viewModel.selectedFocusAreas.isEmpty {
                    Text("Choose one or more areas to emphasize")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private var scheduleSection: some View {
        Section("Schedule") {
            VStack(alignment: .leading, spacing: 12) {
                if viewModel.weeks.count > 1 {
                    Picker("Week", selection: $viewModel.selectedWeek) {
                        ForEach(1...viewModel.weeks.count, id: \.self) { week in
                            Text("Week \(week)").tag(week)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                let days: [(Int, String)] = [
                    (1, "Sunday"), (2, "Monday"), (3, "Tuesday"), (4, "Wednesday"),
                    (5, "Thursday"), (6, "Friday"), (7, "Saturday")
                ]
                
                ForEach(days, id: \.0) { (day, label) in
                    HStack {
                        Text(label)
                        Spacer()
                        if let selection = viewModel.weeks[safe: viewModel.selectedWeek - 1]?.mappings[day] {
                            Button {
                                viewModel.editingDayOfWeek = day
                                viewModel.showingWorkoutPicker = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "dumbbell.fill")
                                    Text(selection.name)
                                }
                            }
                            .buttonStyle(.borderless)
                        } else {
                            Button {
                                viewModel.editingDayOfWeek = day
                                viewModel.showingWorkoutPicker = true
                            } label: {
                                Label("Select Workout", systemImage: "plus.circle")
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                
                Toggle("Deload week", isOn: Binding(
                    get: { viewModel.weeks[safe: viewModel.selectedWeek - 1]?.isDeloadWeek ?? false },
                    set: { newValue in
                        if let index = viewModel.weeks.firstIndex(where: { $0.weekNumber == viewModel.selectedWeek }) {
                            viewModel.weeks[index].isDeloadWeek = newValue
                        }
                    }
                ))
                
                TextField("Notes (optional)", text: Binding(
                    get: { viewModel.weeks[safe: viewModel.selectedWeek - 1]?.notes ?? "" },
                    set: { newValue in
                        if let index = viewModel.weeks.firstIndex(where: { $0.weekNumber == viewModel.selectedWeek }) {
                            viewModel.weeks[index].notes = newValue
                        }
                    }
                ), axis: .vertical)
                .lineLimit(1...3)
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    NavigationStack {
        CustomProgramBuilderView(viewModel: CustomProgramBuilderViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
    }
    .previewEnvironment()
}

// MARK: - Local Types and Helpers

struct WeekScheduleState: Identifiable, Hashable {
    var id: Int { weekNumber }
    let weekNumber: Int
    var mappings: [Int: SelectedWorkout] = [:]
    var notes: String = ""
    var isDeloadWeek: Bool = false
}

struct SelectedWorkout: Hashable {
    let id: String
    let name: String
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        (indices).contains(index) ? self[index] : nil
    }
}

// MARK: - WrappingChips

private struct WrappingChips<Item: Hashable>: View {
    let items: [Item]
    let isSelected: (Item) -> Bool
    let toggle: (Item) -> Void
    let label: (Item) -> any View
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 8)], spacing: 8) {
            ForEach(items, id: \.self) { item in
                Button {
                    toggle(item)
                } label: {
                    HStack(spacing: 6) {
                        AnyView(label(item))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isSelected(item) ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.12))
                    .foregroundStyle(isSelected(item) ? Color.accent : Color.primary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
