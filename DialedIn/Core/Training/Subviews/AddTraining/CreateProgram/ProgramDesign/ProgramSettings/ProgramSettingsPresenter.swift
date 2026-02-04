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

    func onActivatePressed(programId: String) {
        Task {
            do {
                try await interactor.setActiveTrainingProgram(programId: programId)
                router.dismissScreen()
            } catch {
                router.showAlert(error: error)
            }
        }
    }
}
