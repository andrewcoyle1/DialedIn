//
//  CustomProgramBuilderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct CustomProgramBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(ProgramTemplateManager.self) private var programTemplateManager
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    @Environment(AuthManager.self) private var authManager
    
    @State private var name: String = ""
    @State private var descriptionText: String = ""
    @State private var durationWeeks: Int = 8
    @State private var difficulty: DifficultyLevel = .intermediate
    @State private var selectedFocusAreas: Set<FocusArea> = []
    
    @State private var weeks: [WeekScheduleState] = [WeekScheduleState(weekNumber: 1)]
    @State private var selectedWeek: Int = 1
    @State private var editingDayOfWeek: Int?
    @State private var showingWorkoutPicker: Bool = false
    @State private var isSaving: Bool = false
    @State private var isStarting: Bool = false
    @State private var startConfigTemplate: ProgramTemplateModel?
    @State private var showAlert: AnyAppAlert?
    
    private var canContinue: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && durationWeeks > 0
    }
    
    var body: some View {
        List {
            detailsSection
            focusAreasSection
            scheduleSection
        }
        .navigationTitle("Custom Program")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showingWorkoutPicker) {
            if let day = editingDayOfWeek {
                NavigationStack {
                    WorkoutPickerSheet(
                        onSelect: { workout in
                            assign(workout: workout, to: day, inWeek: selectedWeek)
                            showingWorkoutPicker = false
                            editingDayOfWeek = nil
                        },
                        onCancel: {
                            showingWorkoutPicker = false
                            editingDayOfWeek = nil
                        }
                    )
                }
            }
        }
        .sheet(item: $startConfigTemplate) { template in
            ProgramStartConfigView(template: template) { startDate, endDate, customName in
                Task { await startProgram(template: template, startDate: startDate, endDate: endDate, customName: customName) }
            }
        }
        .onChange(of: durationWeeks) { _, newValue in
            resizeWeeks(to: newValue)
        }
        .onAppear {
            resizeWeeks(to: durationWeeks)
        }
        .showCustomAlert(alert: $showAlert)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Menu {
                Button {
                    Task { await saveTemplate() }
                } label: { Label("Save", systemImage: "square.and.arrow.down") }
                
                Button {
                    guard let template = buildTemplate() else { return }
                    startConfigTemplate = template
                } label: { Label("Start…", systemImage: "play.circle.fill") }
                .disabled(!canContinue)
            } label: {
                if isSaving || isStarting {
                    ProgressView()
                } else {
                    Text("Actions")
                }
            }
        }
    }
    
    private var detailsSection: some View {
        Section("Details") {
            TextField("Program name", text: $name)
            TextField("Description (optional)", text: $descriptionText, axis: .vertical)
                .lineLimit(1...4)
            Stepper(value: $durationWeeks, in: 1...52) {
                HStack {
                    Text("Duration")
                    Spacer()
                    Text("\(durationWeeks) week\(durationWeeks == 1 ? "" : "s")")
                        .foregroundStyle(.secondary)
                }
            }
            Picker("Difficulty", selection: $difficulty) {
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
                    isSelected: { selectedFocusAreas.contains($0) },
                    toggle: { area in
                        if selectedFocusAreas.contains(area) {
                            selectedFocusAreas.remove(area)
                        } else {
                            selectedFocusAreas.insert(area)
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
                
                if selectedFocusAreas.isEmpty {
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
                if weeks.count > 1 {
                    Picker("Week", selection: $selectedWeek) {
                        ForEach(1...weeks.count, id: \.self) { week in
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
                        if let selection = weeks[safe: selectedWeek - 1]?.mappings[day] {
                            Button {
                                editingDayOfWeek = day
                                showingWorkoutPicker = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "dumbbell.fill")
                                    Text(selection.name)
                                }
                            }
                            .buttonStyle(.borderless)
                        } else {
                            Button {
                                editingDayOfWeek = day
                                showingWorkoutPicker = true
                            } label: {
                                Label("Select Workout", systemImage: "plus.circle")
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                
                Toggle("Deload week", isOn: Binding(
                    get: { weeks[safe: selectedWeek - 1]?.isDeloadWeek ?? false },
                    set: { newValue in
                        if let index = weeks.firstIndex(where: { $0.weekNumber == selectedWeek }) {
                            weeks[index].isDeloadWeek = newValue
                        }
                    }
                ))
                
                TextField("Notes (optional)", text: Binding(
                    get: { weeks[safe: selectedWeek - 1]?.notes ?? "" },
                    set: { newValue in
                        if let index = weeks.firstIndex(where: { $0.weekNumber == selectedWeek }) {
                            weeks[index].notes = newValue
                        }
                    }
                ), axis: .vertical)
                .lineLimit(1...3)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func resizeWeeks(to count: Int) {
        if count < 1 { return }
        if weeks.count == count { return }
        if weeks.count < count {
            let start = weeks.count + 1
            let end = count
            for week in start...end {
                weeks.append(WeekScheduleState(weekNumber: week))
            }
        } else {
            weeks = Array(weeks.prefix(count))
            if selectedWeek > count { selectedWeek = count }
        }
    }
    
    private func assign(workout: WorkoutTemplateModel, to dayOfWeek: Int, inWeek weekNumber: Int) {
        guard let index = weeks.firstIndex(where: { $0.weekNumber == weekNumber }) else { return }
        weeks[index].mappings[dayOfWeek] = SelectedWorkout(id: workout.workoutId, name: workout.name)
    }
    
    // MARK: - Build/Save/Start
    
    private func buildTemplate() -> ProgramTemplateModel? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, durationWeeks > 0 else { return nil }
        
        let weekTemplates: [WeekTemplate] = weeks.map { week in
            let sortedDays = week.mappings.keys.sorted()
            let schedule = sortedDays.compactMap { day -> DayWorkoutMapping? in
                guard let selected = week.mappings[day] else { return nil }
                return DayWorkoutMapping(dayOfWeek: day, workoutTemplateId: selected.id, workoutName: selected.name)
            }
            return WeekTemplate(
                weekNumber: week.weekNumber,
                workoutSchedule: schedule,
                notes: week.notes.isEmpty ? nil : week.notes,
                isDeloadWeek: week.isDeloadWeek
            )
        }
        
        return ProgramTemplateModel(
            id: UUID().uuidString,
            name: trimmedName,
            description: descriptionText,
            duration: durationWeeks,
            difficulty: difficulty,
            focusAreas: Array(selectedFocusAreas).sorted { $0.rawValue < $1.rawValue },
            weekTemplates: weekTemplates,
            isPublic: false,
            authorId: authManager.auth?.uid
        )
    }
    
    private func saveTemplate() async {
        guard let template = buildTemplate() else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            try await programTemplateManager.create(template)
            dismiss()
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    private func startProgram(template: ProgramTemplateModel, startDate: Date, endDate: Date?, customName: String?) async {
        guard let userId = authManager.auth?.uid else { return }
        isStarting = true
        defer { isStarting = false }
        do {
            _ = try await trainingPlanManager.createPlanFromTemplate(
                template,
                startDate: startDate,
                endDate: endDate,
                userId: userId,
                planName: customName,
                workoutTemplateManager: workoutTemplateManager
            )
            dismiss()
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
}

#Preview {
    NavigationStack {
        CustomProgramBuilderView()
    }
    .previewEnvironment()
}

// MARK: - Local Types and Helpers

private struct WeekScheduleState: Identifiable, Hashable {
    var id: Int { weekNumber }
    let weekNumber: Int
    var mappings: [Int: SelectedWorkout] = [:]
    var notes: String = ""
    var isDeloadWeek: Bool = false
}

private struct SelectedWorkout: Hashable {
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

// MARK: - Workout Picker Sheet

private struct WorkoutPickerSheet: View {
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(AuthManager.self) private var authManager
    
    let onSelect: (WorkoutTemplateModel) -> Void
    let onCancel: () -> Void
    
    @State private var searchText: String = ""
    @State private var officialResults: [WorkoutTemplateModel] = []
    @State private var userResults: [WorkoutTemplateModel] = []
    @State private var isLoading: Bool = false
    @State private var error: AnyAppAlert?
    
    var body: some View {
        List {
            if isLoading {
                Section { ProgressView().frame(maxWidth: .infinity) }
            }
            if !userResults.isEmpty {
                Section {
                    ForEach(userResults, id: \.id) { workout in
                        Button { onSelect(workout) } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(workout.name).font(.body)
                                if let desc = workout.description, !desc.isEmpty {
                                    Text(desc).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Your Workouts")
                }
            }
            if !officialResults.isEmpty {
                Section {
                    ForEach(officialResults, id: \.id) { workout in
                        Button { onSelect(workout) } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(workout.name).font(.body)
                                if let desc = workout.description, !desc.isEmpty {
                                    Text(desc).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Official Workouts")
                }
            }
            if !isLoading && userResults.isEmpty && officialResults.isEmpty {
                Section {
                    Text("No workouts found")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Select Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: onCancel) }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) {
            Task { await runSearch() }
        }
        .task {
            await loadTopWorkouts()
        }
        .showCustomAlert(alert: $error)
    }
    
    private func loadTopWorkouts() async {
        isLoading = true
        defer { isLoading = false }
        // Include local and remote workouts
        let localAll = (try? workoutTemplateManager.getAllLocalWorkoutTemplates()) ?? []
        let uid = authManager.auth?.uid
        let remoteTop = (try? await workoutTemplateManager.getTopWorkoutTemplatesByClicks(limitTo: 15)) ?? []
        var remoteUser: [WorkoutTemplateModel] = []
        if let id = uid {
            remoteUser = (try? await workoutTemplateManager.getWorkoutTemplatesForAuthor(authorId: id)) ?? []
        }
        let combined = mergeUnique(localAll + remoteTop + remoteUser)
        userResults = combined.filter { $0.authorId == uid }
        officialResults = combined.filter { $0.authorId != uid }
    }
    
    private func runSearch() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { await loadTopWorkouts(); return }
        isLoading = true
        defer { isLoading = false }
        // Local and remote search
        let localAll = (try? workoutTemplateManager.getAllLocalWorkoutTemplates()) ?? []
        let uid = authManager.auth?.uid
        let localMatches = localAll.filter { tmpl in
            tmpl.name.localizedCaseInsensitiveContains(query)
        }
        let remoteFound = (try? await workoutTemplateManager.getWorkoutTemplatesByName(name: query)) ?? []
        var remoteUser: [WorkoutTemplateModel] = []
        if let id = uid {
            remoteUser = (try? await workoutTemplateManager.getWorkoutTemplatesForAuthor(authorId: id)) ?? []
        }
        let combined = mergeUnique(localMatches + remoteFound + remoteUser)
        userResults = combined.filter { $0.authorId == uid }
        officialResults = combined.filter { $0.authorId != uid }
    }
    
    private func mergeUnique(_ items: [WorkoutTemplateModel]) -> [WorkoutTemplateModel] {
        var seen = Set<String>()
        var merged: [WorkoutTemplateModel] = []
        for item in items where !seen.contains(item.workoutId) {
            seen.insert(item.workoutId)
            merged.append(item)
        }
        return merged
    }
}
