//
//  DashboardInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol DashboardInteractor {
    var notificationsABTest: Bool { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: DashboardInteractor { }
