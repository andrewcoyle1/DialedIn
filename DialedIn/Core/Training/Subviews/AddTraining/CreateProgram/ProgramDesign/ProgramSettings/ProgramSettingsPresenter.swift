import SwiftUI

@Observable
@MainActor
class ProgramSettingsPresenter {
    
    private let interactor: ProgramSettingsInteractor
    private let router: ProgramSettingsRouter
    
    init(interactor: ProgramSettingsInteractor, router: ProgramSettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }

    func onActivatePressed(program: TrainingProgram) {
        Task {
            do {
                try await interactor.upsertTrainingProgram(program: program)
                try await interactor.setActiveTrainingProgram(programId: program.id)
                router.dismissScreen()
            } catch {
                router.showAlert(error: error)
            }
        }
    }
}
