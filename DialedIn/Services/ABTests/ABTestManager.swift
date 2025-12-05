//
//  ABTestManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

@Observable
class ABTestManager {
    private let service: ABTestService
    private let logger: LogManager
    var activeTests: ActiveABTests
    
    init(service: ABTestService, logger: LogManager) {
        self.service = service
        self.activeTests = service.activeTests
        self.logger = logger
        self.configure()
    }
    
    private func configure() {
        Task {
            do {
                activeTests = try await service.fetchUpdatedConfig()
                logger.trackEvent(event: Event.fetchRemoteConfigSuccess)
            } catch {
                logger.trackEvent(event: Event.fetchRemoteConfigFail(error: error))
            }
        }
        activeTests = service.activeTests
        logger.addUserProperties(dict: activeTests.eventParameters, isHighPriority: false)
    }
    
    func override(updatedTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updatedTests)
        configure()
    }
    
    enum Event: LoggableEvent {
        case fetchRemoteConfigSuccess
        case fetchRemoteConfigFail(error: Error)

        var eventName: String {
            switch self {
            case .fetchRemoteConfigSuccess: return "ABMan_FetchRemote_Success"
            case .fetchRemoteConfigFail: return "ABMan_FetchRemote_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .fetchRemoteConfigFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .fetchRemoteConfigFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}
