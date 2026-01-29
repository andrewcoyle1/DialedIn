//
//  SwiftfulLogging_Alias.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/01/2026.
//

@_exported import SwiftfulLogging
@_exported import SwiftfulLoggingMixpanel
@_exported import SwiftfulLoggingFirebaseAnalytics
@_exported import SwiftfulLoggingFirebaseCrashlytics

typealias LogManager = SwiftfulLogging.LogManager
typealias LoggableEvent = SwiftfulLogging.LoggableEvent
typealias LogType = SwiftfulLogging.LogType
typealias LogService = SwiftfulLogging.LogService
typealias AnyLoggableEvent = SwiftfulLogging.AnyLoggableEvent
typealias ConsoleService = SwiftfulLogging.ConsoleService
typealias MixpanelService = SwiftfulLoggingMixpanel.MixpanelService
typealias FirebaseAnalyticsService = SwiftfulLoggingFirebaseAnalytics.FirebaseAnalyticsService
typealias FirebaseCrashlyticsService = SwiftfulLoggingFirebaseCrashlytics.FirebaseCrashlyticsService
