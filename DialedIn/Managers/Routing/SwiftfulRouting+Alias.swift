//
//  SwiftfulRouting+Alias.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/01/2026.
//

import SwiftUI

@_exported import SwiftfulRouting
typealias RouterView = SwiftfulRouting.RouterView
typealias Router = SwiftfulRouting.AnyRouter
typealias AlertStyle = SwiftfulRouting.AlertStyle

extension RoutingLogType {

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
extension LogManager: @retroactive RoutingLogger {
    public func trackEvent(event: any RoutingLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }

    public func trackScreenView(event: any RoutingLogEvent) {
        trackScreenView(event: AnyLoggableEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type))
    }
}
