//
//  MockUserWeightServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockUserWeightServices: UserWeightServices {
    let remote: RemoteUserWeightService
    let local: LocalUserWeightService
    
    init(delay: Double = 0, showError: Bool = false) {
        self.remote = MockRemoteUserWeightService(delay: delay, showError: showError)
        self.local = MockLocalUserWeightService(delay: delay, showError: showError)
    }
}
