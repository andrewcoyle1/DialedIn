//
//  LocalPushService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

protocol LocalPushService {
    func requestAuthorisation() async throws -> Bool
    func canRequestAuthorisation() async -> Bool
}
