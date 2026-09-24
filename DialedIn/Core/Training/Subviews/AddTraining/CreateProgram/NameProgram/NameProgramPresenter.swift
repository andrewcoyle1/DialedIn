import SwiftUI

@Observable
@MainActor
class NameProgramPresenter {
    
    private let interactor: NameProgramInteractor
    private let router: NameProgramRouter
    
    var programName: String
    
    private var trimmedName: String { programName.trimmingCharacters(in: .whitespacesAndNewlines) }

    var canSave: Bool { !trimmedName.isEmpty }
    
    init(interactor: NameProgramInteractor, router: NameProgramRouter) {
        self.interactor = interactor
        self.router = router
        
        self.programName = Date.now.formattedDate
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
    
    func onNextPressed(delegate: NameProgramDelegate) {
        guard canSave else { return }
        router.showProgramIconView(delegate: ProgramIconDelegate(onComplete: delegate.onComplete, name: trimmedName))
    }
    
}

extension NameProgramPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "NameProgramView_Appear"
            case .onDisappear: return "NameProgramView_Disappear"
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
