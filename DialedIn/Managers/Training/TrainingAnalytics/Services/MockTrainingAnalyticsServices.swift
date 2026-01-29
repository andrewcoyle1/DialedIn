//
//  MockTrainingAnalyticsServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockTrainingAnalyticsServices: TrainingAnalyticsServices {
    let remote: RemoteTrainingAnalyticsService
    let local: LocalTrainingAnalyticsService
    
    init(delay: Double = 0, showError: Bool = false) {
        self.remote = MockRemoteTrainingAnalyticsService()
        self.local = MockLocalTrainingAnalyticsService(delay: delay, showError: showError)
    }
}
