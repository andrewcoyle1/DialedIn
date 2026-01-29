//
//  MockGoalServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockGoalServices: GoalServices {
    let remote: RemoteGoalService
    let local: LocalGoalService
    
    init(delay: Double = 0, showError: Bool = false) {
        self.remote = MockRemoteGoalService(delay: delay, showError: showError)
        self.local = MockLocalGoalService(delay: delay, showError: showError)
    }
}
