import SwiftUI

@Observable
@MainActor
class ProgramDesignPresenter {
    
    private let interactor: ProgramDesignInteractor
    private let router: ProgramDesignRouter
    
    var program: TrainingProgram
    
    static var defaultDayPlans: [DayPlan] = [
        DayPlan(name: "Rest")
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
        
        self.dayPlans = Self.defaultDayPlans
        self.selectedDayPlan = Self.defaultDayPlans.first ?? DayPlan(name: "Rest")
    }
    
    func onAddDayPressed() {
        dayPlans.append(.init(name: "Rest"))
        program.dayPlans = dayPlans
    }
    
    func onDayPlanSelected(_ dayPlan: DayPlan) {
        selectedDayPlan = dayPlan
    }
    
    func onRemoveDayPlanPressed() {
        guard canRemoveDayPlan else { return }
        if let index = dayPlans.firstIndex(where: { $0.id == selectedDayPlan.id }) {
            dayPlans.remove(at: index)
            selectedDayPlan = dayPlans.first ?? DayPlan(name: "Rest")
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

struct TrainingProgram: Identifiable {
    var id: String
    var name: String
    var icon: String
    var colour: Color
    var numMicrocycles: Int = 8
    var deload: DeloadType = .none
    var periodisation: Bool = false
    var dayPlans: [DayPlan] = defaultDayPlans
    
    enum DeloadType: String, Codable {
        case none
        case start
        case end
        
        var title: String {
            switch self {
            case .none: return "None"
            case .start: return "First Cycle"
            case .end: return "Last Cycle"
            }
        }
        
        var description: String {
            switch self {
            case .none: return "Train continuously without scheduled reductions in intensity or volume."
            case .start: return "Start each training block with a lower-intensity cycle to ease into new workloads and reduce soreness."
            case .end: return "Finish each training block with a lighter cycle to promote recovery and readiness for the next phase."
            }
        }
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        icon: String,
        colour: Color,
        numMicrocycles: Int = 8,
        deload: DeloadType = .none,
        periodisation: Bool = false,
        dayPlans: [DayPlan] = defaultDayPlans
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colour = colour
        self.numMicrocycles = numMicrocycles
        self.deload = deload
        self.periodisation = periodisation
        self.dayPlans = dayPlans
    }

    static var defaultDayPlans: [DayPlan] = [
        DayPlan(name: "Rest")
    ]

}
struct DayPlan: Identifiable {
    let id: String = UUID().uuidString
    var name: String
    
    var exercises: [ExerciseTemplateModel] = []
}
