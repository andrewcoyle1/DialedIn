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
    
    var canRemoveDayPlan: Bool {
        dayPlans.count > 1
    }
    
    init(interactor: ProgramDesignInteractor, router: ProgramDesignRouter, program: TrainingProgram) {
        self.interactor = interactor
        self.router = router
        self.program = program
        
        let uid = interactor.userId
        self.dayPlans = Self.defaultDayPlans
        
        self.selectedDayPlan = DayPlan(
            id: UUID().uuidString,
            authorId: uid ?? "",
            name: "Rest",
            exercises: []
        )
    }
    
    func onAddDayPressed() {
        dayPlans.append(
            DayPlan(
                id: UUID().uuidString,
                authorId: userId,
                name: "Rest",
                exercises: []
            )
        )
        program.dayPlans = dayPlans
    }
    
    func onDayPlanSelected(_ dayPlan: DayPlan) {
        selectedDayPlan = dayPlan
    }
    
    func onRemoveDayPlanPressed() {
        guard canRemoveDayPlan else { return }
        if let index = dayPlans.firstIndex(where: { $0.id == selectedDayPlan.id }) {
            dayPlans.remove(at: index)
            selectedDayPlan = dayPlans.first!
            program.dayPlans = dayPlans
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
        
    }
    
    func onSavePressed(delegate: ProgramDesignDelegate) {
        
    }
}
