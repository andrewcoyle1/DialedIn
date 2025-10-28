//
//  ABTestManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

@Observable
class ABTestManager {
    private let remote: RemoteABTestService
    private let local: LocalABTestService
    
    init(services: ABTestServices) { 
        self.remote = services.remote
        self.local = services.local
    }
}

protocol ABTestServices {
    var remote: RemoteABTestService { get }
    var local: LocalABTestService { get }
}

protocol RemoteABTestService {
    
}

protocol LocalABTestService {
    
}

struct MockABTestServices: ABTestServices {
    let remote: RemoteABTestService
    let local: LocalABTestService
    
    init(delay: Double, showError: Bool) {
        self.remote = MockRemoteABTestService(delay: delay, showError: showError)
        self.local = MockLocalABTestService(delay: delay, showError: showError)
    }
}

struct MockRemoteABTestService: RemoteABTestService {
    let delay: Double
    let showError: Bool
    
//    init(delay: Double, showError: Bool) {
//        self.delay = delay
//        self.showError = showError
//    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
}

struct MockLocalABTestService: LocalABTestService {
    let delay: Double
    let showError: Bool
    
//    init(delay: Double, showError: Bool) {
//        self.delay = delay
//        self.showError = showError
//    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
}

struct ProductionABTestServices: ABTestServices {
    let remote: RemoteABTestService = ProductionRemoteABTestService()
    let local: LocalABTestService = ProductionLocalABTestService()
}

struct ProductionRemoteABTestService: RemoteABTestService {
    
}

struct ProductionLocalABTestService: LocalABTestService {
    
}
