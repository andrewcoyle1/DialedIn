//
//  CustomProgramBuilderViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol CustomProgramBuilderInteractor {
    var auth: UserAuthInfo? { get }
    func create(_ template: ProgramTemplateModel) async throws
    func createPlanFromTemplate(
        _ template: ProgramTemplateModel,
        startDate: Date,
        endDate: Date?,
        userId: String,
        planName: String?
    ) async throws -> TrainingPlan
}

extension CoreInteractor: CustomProgramBuilderInteractor { }

@Observable
@MainActor
class CustomProgramBuilderViewModel {
    private let interactor: CustomProgramBuilderInteractor
    
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
    var showingWorkoutPicker: Bool = false
    var startConfigTemplate: ProgramTemplateModel?
    var showAlert: AnyAppAlert?
    
    var canContinue: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && durationWeeks > 0
    }
    
    init(
        interactor: CustomProgramBuilderInteractor
    ) {
        self.interactor = interactor
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
    
    func assign(workout: WorkoutTemplateModel, to dayOfWeek: Int, inWeek weekNumber: Int) {
        guard let index = weeks.firstIndex(where: { $0.weekNumber == weekNumber }) else { return }
        weeks[index].mappings[dayOfWeek] = SelectedWorkout(id: workout.workoutId, name: workout.name)
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
    
    func saveTemplate(onDismiss: () -> Void) async {
        guard let template = buildTemplate() else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            try await interactor.create(template)
            onDismiss()
        } catch {
            showAlert = AnyAppAlert(error: error)
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
            showAlert = AnyAppAlert(error: error)
        }
    }
}
