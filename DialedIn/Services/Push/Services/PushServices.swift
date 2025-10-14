//
//  PushServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

protocol PushServices {
    var local: LocalPushService { get }
}

struct MockPushServices: PushServices {
    let local: LocalPushService

    init(canRequestAuthorisation: Bool = true, delay: Double = 0, showError: Bool = false) {
        self.local = MockLocalPushService(canRequestAuthorisation: canRequestAuthorisation, delay: delay, showError: showError)
    }
}

struct ProductionPushServices: PushServices {
    let local: LocalPushService = ProductionLocalPushService()
}
