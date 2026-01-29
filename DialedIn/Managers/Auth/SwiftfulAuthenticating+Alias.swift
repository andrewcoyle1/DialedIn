//
//  SwiftfulAuthenticating+Alias.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/01/2026.
//

import SwiftUI
import Firebase

@_exported import SwiftfulAuthenticating
@_exported import SwiftfulAuthenticatingFirebase
typealias UserAuthInfo = SwiftfulAuthenticating.UserAuthInfo
typealias AuthManager = SwiftfulAuthenticating.AuthManager
typealias MockAuthService = SwiftfulAuthenticating.MockAuthService

extension AuthLogType {

    var type: LogType {
        switch self {
        case .info:
            return .info
        case .analytic:
            return .analytic
        case .warning:
            return .warning
        case .severe:
            return .severe
        }
    }
}

extension LogManager: @retroactive AuthLogger {
    public func trackEvent(event: any AuthLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
}
