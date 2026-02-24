//
//  NotificationsPermissionsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol NotificationsPermissionsInteractor: GlobalInteractor {
    func requestPushAuthorization() async throws -> Bool
    func canRequestHealthDataAuthorisation() -> Bool
}

extension CoreInteractor: NotificationsPermissionsInteractor { }
