//
//  GlobalInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/01/2026.
//

@MainActor
protocol GlobalInteractor {
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
    func trackEvent(event: AnyLoggableEvent)
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
    
    func playHaptic(option: HapticOption)

    /// Shows an app-level toast. Lives here beside `playHaptic` for the same reason: it is feedback
    /// every screen may need, and it has to be reachable from work that outlives the screen that
    /// started it.
    func showAppToast(_ toast: AppToast)
}
