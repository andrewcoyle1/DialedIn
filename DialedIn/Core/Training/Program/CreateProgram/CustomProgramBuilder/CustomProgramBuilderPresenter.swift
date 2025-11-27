//
//  CustomProgramBuilderPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI


@Observable
@MainActor
class CustomProgramBuilderPresenter {
    private let interactor: CustomProgramBuilderInteractor
    private let router: CustomProgramBuilderRouter

    private(set) var isSaving: Bool = false
    private(set) var isStarting: Bool = false
    var name: String = ""
    var descriptionText: String = ""
    var durationWeeks: Int = 8
    var difficulty: DifficultyLevel = .intermediate
    var selectedFocusAreas: Set<FocusArea> = []
    var weeks: [WeekScheduleState] = [WeekScheduleState(weekNumber: 1)]
    var selectedWeek: Int = 1
    var editingDayOfWeek: Int?
    var showingCopyWeekPicker: Bool = false
    var startConfigTemplate: ProgramTemplateModel?

    var canContinue: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && durationWeeks > 0
    }
    
    init(
        interactor: CustomProgramBuilderInteractor,
        router: CustomProgramBuilderRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func resizeWeeks(to count: Int) {
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

    func onStartProgramPressed() {
        guard let template = buildTemplate() else { return }
        router.showProgramStartConfigView(delegate: ProgramStartConfigDelegate(template: template, onStart: { startDate, endDate, customName in
            Task {
                await self.startProgram(
                    template: template,
                    startDate: startDate,
                    endDate: endDate,
                    customName: customName,
                    onDismiss: {
                        self.dismissScreen()
                    }
                )
            }
        }))

    }
    func assign(workout: WorkoutTemplateModel, to dayOfWeek: Int, inWeek weekNumber: Int) {
        guard let index = weeks.firstIndex(where: { $0.weekNumber == weekNumber }) else { return }
        weeks[index].mappings[dayOfWeek] = SelectedWorkout(id: workout.workoutId, name: workout.name)
    }
    
    func copySchedule(from sourceWeek: Int, to targetWeek: Int) -> Bool {
        // Validate that both weeks exist and are different
        guard sourceWeek != targetWeek,
              sourceWeek >= 1,
              targetWeek >= 1,
              sourceWeek <= weeks.count,
              targetWeek <= weeks.count else {
            return false
        }
        
        // Find source week
        guard let sourceIndex = weeks.firstIndex(where: { $0.weekNumber == sourceWeek }),
              let targetIndex = weeks.firstIndex(where: { $0.weekNumber == targetWeek }) else {
            return false
        }
        
        // Copy only the mappings dictionary (creates a copy since Dictionary is a value type)
        weeks[targetIndex].mappings = weeks[sourceIndex].mappings
        
        return true
    }
    
    // MARK: - Build/Save/Start
    
    func buildTemplate() -> ProgramTemplateModel? {
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
            authorId: interactor.auth?.uid
        )
    }

    func onWorkoutPickerPressed(day: Int) {
        let delegate = WorkoutPickerDelegate(
            onSelect: { workout in
                self.assign(
                    workout: workout,
                    to: day,
                    inWeek: self.selectedWeek
                )
                self.editingDayOfWeek = nil
            },
            onCancel: {
                self.editingDayOfWeek = nil
            }
        )
        router.showWorkoutPickerView(delegate: delegate)
    }

    func onCopyWeekPickerPressed() {
        let delegate = CopyWeekPickerDelegate(
            availableWeeks: (1..<self.selectedWeek).map { $0 },
            onSelect: { sourceWeek in
                let success = self.copySchedule(from: sourceWeek, to: self.selectedWeek)
                if !success {
                    self.router.showSimpleAlert(
                        title: "Error",
                        subtitle: "Failed to copy schedule. Please try again."
                    )
                }
            }
        )
        router.showCopyWeekPickerView(delegate: delegate)
    }

    func saveTemplate() async {
        guard let template = buildTemplate() else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            try await interactor.create(template)
            dismissScreen()
        } catch {
            router.showAlert(error: error)
        }
    }
    
    func startProgram(template: ProgramTemplateModel, startDate: Date, endDate: Date?, customName: String?, onDismiss: @escaping () -> Void) async {
        guard let userId = interactor.auth?.uid else { return }
        isStarting = true
        defer { isStarting = false }
        do {
            _ = try await interactor.createPlanFromTemplate(
                template,
                startDate: startDate,
                endDate: endDate,
                userId: userId,
                planName: customName
            )
            onDismiss()
        } catch {
            router.showAlert(error: error)
        }
    }

    func dismissScreen() {
        router.dismissScreen()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}

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
