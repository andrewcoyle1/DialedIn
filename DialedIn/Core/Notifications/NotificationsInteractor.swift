//
//  NotificationsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import UserNotifications

@MainActor
protocol NotificationsInteractor: GlobalInteractor {
    func requestPushAuthorization() async throws -> Bool
}

extension CoreInteractor: NotificationsInteractor { }
