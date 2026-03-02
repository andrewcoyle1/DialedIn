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
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onActivatePressed(program: TrainingProgram) {
        Task {
            do {
                try await interactor.saveTrainingProgram(trainingProgram: program)
                try await interactor.setActiveTrainingProgram(programId: program.id)
                router.dismissScreen()
            } catch {
                router.showAlert(error: error)
            }
        }
    }
    
}

extension ProgramSettingsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "ProgramSettingsView_Appear"
            case .onDisappear: return "ProgramSettingsView_Disappear"
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
