import SwiftUI

@Observable
@MainActor
class ProgramDesignPresenter {
    
    private let interactor: ProgramDesignInteractor
    private let router: ProgramDesignRouter
    
    var userId: String {
        interactor.userId ?? ""
    }
    
    var favouriteGymProfile: GymProfileModel? {
        interactor.favouriteGymProfile
    }
    
    var program: TrainingProgram
    
    static let defaultWorkoutTemplateModels: [WorkoutTemplateModel] = [
        
    ]
    
    var dayPlans: [WorkoutTemplateModel]
    
    var selectedWorkoutTemplateModel: WorkoutTemplateModel
    
    var selectedWorkoutTemplateModelExercises: Binding<[WorkoutTemplateExercise]> {
        Binding(
            get: { self.selectedWorkoutTemplateModel.exercises },
            set: { [weak self] newValue in
                guard let self else { return }
                guard let index = self.dayPlans.firstIndex(where: { $0.id == self.selectedWorkoutTemplateModel.id }) else { return }
                self.dayPlans[index].exercises = newValue
                self.selectedWorkoutTemplateModel = self.dayPlans[index]
                self.recalculateAutoWorkoutTemplateModelNames()
            }
        )
    }
    
    var canRemoveWorkoutTemplateModel: Bool {
        dayPlans.count > 1
    }

    var isProgramActive: Bool {
        interactor.activeTrainingProgram?.id == program.id
    }
    
    init(interactor: ProgramDesignInteractor, router: ProgramDesignRouter, program: TrainingProgram) {
        self.interactor = interactor
        self.router = router
        self.program = program
        
        let uid = interactor.userId
        let initialPlans = program.dayPlans.isEmpty ? Self.defaultWorkoutTemplateModels : program.dayPlans
        self.dayPlans = initialPlans

        if let firstPlan = initialPlans.first {
            self.selectedWorkoutTemplateModel = firstPlan
        } else {
            self.selectedWorkoutTemplateModel = WorkoutTemplateModel(
                id: UUID().uuidString,
                authorId: uid ?? "",
                name: "Rest",
                exercises: []
            )
            self.dayPlans = [self.selectedWorkoutTemplateModel]
        }
        self.program.dayPlans = self.dayPlans
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
    
    func onAddDayPressed() {
        let newWorkoutTemplateModel = WorkoutTemplateModel(
            id: UUID().uuidString,
            authorId: userId,
            name: "Rest Day",
            exercises: []
        )
        dayPlans.append(
            newWorkoutTemplateModel
        )
        selectedWorkoutTemplateModel = newWorkoutTemplateModel
        recalculateAutoWorkoutTemplateModelNames()
    }
    
    func onWorkoutTemplateModelSelected(_ dayPlan: WorkoutTemplateModel) {
        selectedWorkoutTemplateModel = dayPlan
    }
    
    func onRemoveWorkoutTemplateModelPressed() {
        guard canRemoveWorkoutTemplateModel else { return }
        if let index = dayPlans.firstIndex(where: { $0.id == selectedWorkoutTemplateModel.id }) {
            dayPlans.remove(at: index)
            selectedWorkoutTemplateModel = dayPlans.first!
            recalculateAutoWorkoutTemplateModelNames()
        }
    }
    
    func onRenameWorkoutTemplateModelPressed() {
        let selectedId = selectedWorkoutTemplateModel.id
        router.showRenameWorkoutTemplateModelView(
            delegate: RenameWorkoutTemplateModelDelegate(
                initialName: selectedWorkoutTemplateModel.name,
                onSave: { [weak self] newName in
                    guard let self else { return }
                    guard let index = self.dayPlans.firstIndex(where: { $0.id == selectedId }) else { return }
                    self.dayPlans[index].name = newName
                    self.selectedWorkoutTemplateModel = self.dayPlans[index]
                    self.program.dayPlans = self.dayPlans
                }
            )
        )
    }
    
    func onAddExercisePressed() {
        router.showExercisePickerView(delegate: ExercisePickerDelegate(selectedExercises: .constant([])))
    }
    
    func onProgramSettingsPressed(program: Binding<TrainingProgram>) {
        router.showProgramSettingsView(program: program)
    }
    
    func onActivatePressed(delegate: ProgramDesignDelegate) {
        router.showAlert(title: "Save Workout Templates", subtitle: "Would you like to save the workout templates in the training program for use independently?") {
            AnyView(
                VStack {
                    Button {
                        Task {
                            for workoutTemplate in self.dayPlans {
                                try await self.interactor.saveWorkoutTemplate(workoutTemplate: workoutTemplate, image: nil)
                            }
                            try await self.activateProgram(delegate: delegate)
                        }
                    } label: {
                        Text("Yes")
                    }
                    Button {
                        Task {
                            try await self.activateProgram(delegate: delegate)
                        }
                    } label: {
                        Text("No")
                    }
                    Button(role: .close) { }
                }
            )
        }
    }
    
    private func activateProgram(delegate: ProgramDesignDelegate) async throws {
        Task {
            do {
                try await interactor.saveTrainingProgram(trainingProgram: program)
                try await interactor.setActiveTrainingProgram(programId: program.id)
                if delegate.onComplete != nil {
                    handleNavigation()
                } else {
                    router.dismissEnvironment()
                }
            } catch {
                router.showAlert(error: error)
            }
        }

    }

    // MARK: Handle Navigation
    func handleNavigation() {
        if let currentUser = interactor.currentUser {
            let step = currentUser.inferredOnboardingStep
            route(to: step)
        }
    }

    private func route(to step: OnboardingStep) {
        switch step {
        case .auth, .subscription:
            router.showCompleteAccountSetupView()

        case .completeAccountSetup:
            router.showCompleteAccountSetupView()

        case .notifications:
            router.showNotificationsPermissionsView()

        case .healthData:
            router.showOnboardingHealthDataView()

        case .healthDisclaimer:
            router.showHealthDisclaimerView()

        case .goalSetting:
            router.showGoalSettingView()

        case .gymProfileSetup:
            router.showCreateGymProfileView(delegate: CreateGymProfileDelegate(onComplete: self.handleNavigation))

        case .trainingProgramSetup:
            router.showOnboardingTrainingProgramView(
                delegate: CreateProgramDelegate(
                    onComplete: { [weak self] in
                        guard let self else { return }
                        Task { @MainActor in
                            self.handleNavigation()
                        }
                    }
                )
            )

        case .customiseProgram:
            router.showCustomisingDietProgramView()

        case .complete:
            router.showOnboardingCompletedView()
        }
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }

    func onSavePressed(delegate: ProgramDesignDelegate) {
        Task {
            do {
                try await interactor.saveTrainingProgram(trainingProgram: program)
                router.dismissEnvironment()
            } catch {
                router.showAlert(error: error)
            }
        }
    }

    private func recalculateAutoWorkoutTemplateModelNames() {
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
            
            if isDefaultWorkoutTemplateModelName(dayPlans[index].name) {
                dayPlans[index].name = desiredName
            }
        }
        
        if let selectedIndex = dayPlans.firstIndex(where: { $0.id == selectedWorkoutTemplateModel.id }) {
            selectedWorkoutTemplateModel = dayPlans[selectedIndex]
        }
        program.dayPlans = dayPlans
    }
    
    private func isDefaultWorkoutTemplateModelName(_ name: String) -> Bool {
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

extension ProgramDesignPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "ProgramDesignView_Appear"
            case .onDisappear: return "ProgramDesignView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
