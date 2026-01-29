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
}
