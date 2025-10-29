//
//  MockPushServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockPushServices: PushServices {
    let local: LocalPushService

    init(canRequestAuthorisation: Bool = true, delay: Double = 0, showError: Bool = false) {
        self.local = MockLocalPushService(canRequestAuthorisation: canRequestAuthorisation, delay: delay, showError: showError)
    }
}
