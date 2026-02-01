import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class AboutPresenter {
    
    private let interactor: AboutInteractor
    private let router: AboutRouter

    let appVersion: String = SwiftfulUtilities.Utilities.appVersion ?? ""
    let appBuild: String = SwiftfulUtilities.Utilities.buildNumber ?? ""

    init(interactor: AboutInteractor, router: AboutRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onLicencesPressed() {

    }

    func onViewAppear(delegate: AboutDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: AboutDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension AboutPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: AboutDelegate)
        case onDisappear(delegate: AboutDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "AboutView_Appear"
            case .onDisappear:              return "AboutView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
//            default:
//                return nil
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
