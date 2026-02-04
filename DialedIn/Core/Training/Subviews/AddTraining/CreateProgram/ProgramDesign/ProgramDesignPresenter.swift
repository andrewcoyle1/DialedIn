import SwiftUI

@Observable
@MainActor
class ProgramDesignPresenter {
    
    private let interactor: ProgramDesignInteractor
    private let router: ProgramDesignRouter
    
    var userId: String {
        interactor.userId ?? ""
    }
    
    var program: TrainingProgram
    
    static var defaultDayPlans: [DayPlan] = [
        
    ]
    
    var dayPlans: [DayPlan]
    
    var selectedDayPlan: DayPlan

    var gymProfile: GymProfileModel?
    
    var selectedDayPlanExercises: Binding<[WorkoutTemplateExercise]> {
        Binding(
            get: { self.selectedDayPlan.exercises },
            set: { [weak self] newValue in
                guard let self else { return }
                guard let index = self.dayPlans.firstIndex(where: { $0.id == self.selectedDayPlan.id }) else { return }
                self.dayPlans[index].exercises = newValue
                self.selectedDayPlan = self.dayPlans[index]
                self.recalculateAutoDayPlanNames()
            }
        )
    }
    
    var canRemoveDayPlan: Bool {
        dayPlans.count > 1
    }
    
    init(interactor: ProgramDesignInteractor, router: ProgramDesignRouter, program: TrainingProgram) {
        self.interactor = interactor
        self.router = router
        self.program = program
        
        let uid = interactor.userId
        self.dayPlans = Self.defaultDayPlans
        
        if let firstPlan = Self.defaultDayPlans.first {
            self.selectedDayPlan = firstPlan
        } else {
            self.selectedDayPlan = DayPlan(
                id: UUID().uuidString,
                authorId: uid ?? "",
                name: "Rest",
                exercises: []
            )
            self.dayPlans = [self.selectedDayPlan]
        }
        self.program.dayPlans = self.dayPlans

        Task {
            await loadFavouriteGymProfile()
        }
    }

    func loadFavouriteGymProfile() async {
        do {
            gymProfile = try await interactor.readFavouriteGymProfile()
        } catch {
            gymProfile = nil
        }
    }
    
    func onAddDayPressed() {
        let newDayPlan = DayPlan(
            id: UUID().uuidString,
            authorId: userId,
            name: "Rest Day",
            exercises: []
        )
        dayPlans.append(
            newDayPlan
        )
        selectedDayPlan = newDayPlan
        recalculateAutoDayPlanNames()
    }
    
    func onDayPlanSelected(_ dayPlan: DayPlan) {
        selectedDayPlan = dayPlan
    }
    
    func onRemoveDayPlanPressed() {
        guard canRemoveDayPlan else { return }
        if let index = dayPlans.firstIndex(where: { $0.id == selectedDayPlan.id }) {
            dayPlans.remove(at: index)
            selectedDayPlan = dayPlans.first!
            recalculateAutoDayPlanNames()
        }
    }
    
    func onRenameDayPlanPressed() {
        let selectedId = selectedDayPlan.id
        router.showRenameDayPlanView(
            delegate: RenameDayPlanDelegate(
                initialName: selectedDayPlan.name,
                onSave: { [weak self] newName in
                    guard let self else { return }
                    guard let index = self.dayPlans.firstIndex(where: { $0.id == selectedId }) else { return }
                    self.dayPlans[index].name = newName
                    self.selectedDayPlan = self.dayPlans[index]
                    self.program.dayPlans = self.dayPlans
                }
            )
        )
    }
    
    func onAddExercisePressed() {
        router.showAddExercisesView(delegate: AddExerciseModalDelegate(selectedExercises: .constant([])))
    }
    
    func onProgramSettingsPressed(program: Binding<TrainingProgram>) {
        router.showProgramSettingsView(program: program)
    }
    
    func onActivatePressed(delegate: ProgramDesignDelegate) {
        Task {
            do {
                try await interactor.upsertTrainingProgram(program: program)
                try await interactor.setActiveTrainingProgram(programId: program.id)
                router.dismissEnvironment()

            } catch {
                router.showAlert(error: error)
            }
        }
    }
    
    func onSavePressed(delegate: ProgramDesignDelegate) {
        Task {
            do {
                try await interactor.upsertTrainingProgram(program: program)
                router.dismissEnvironment()
            } catch {
                router.showAlert(error: error)
            }
        }
    }

    private func recalculateAutoDayPlanNames() {
        var workoutIndex = 0
        for index in dayPlans.indices {
            let isRestDay = dayPlans[index].exercises.isEmpty
            let desiredName: String
            if isRestDay {
                desiredName = "Rest Day"
            } else {
                desiredName = "Workout \(letterForWorkoutIndex(workoutIndex))"
                workoutIndex += 1
            }
            
            if isDefaultDayPlanName(dayPlans[index].name) {
                dayPlans[index].name = desiredName
            }
        }
        
        if let selectedIndex = dayPlans.firstIndex(where: { $0.id == selectedDayPlan.id }) {
            selectedDayPlan = dayPlans[selectedIndex]
        }
        program.dayPlans = dayPlans
    }
    
    private func isDefaultDayPlanName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed == "Rest" || trimmed == "Rest Day" {
            return true
        }
        if trimmed.hasPrefix("Workout "), let suffix = trimmed.split(separator: " ").last {
            return suffix.count == 1 && suffix.first?.isLetter == true
        }
        return false
    }
    
    private func letterForWorkoutIndex(_ index: Int) -> String {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        guard index >= 0 else { return "A" }
        if index < alphabet.count {
            return String(alphabet[index])
        }
        return "\(String(alphabet[index % alphabet.count]))\(index / alphabet.count)"
    }
}
