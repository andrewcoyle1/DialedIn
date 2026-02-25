//
//  ActivityInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ActivityInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ActivityInteractor { }
