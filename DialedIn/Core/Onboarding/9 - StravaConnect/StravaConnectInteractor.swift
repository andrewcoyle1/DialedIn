//
//  StravaConnectInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 09/03/2026.
//

@MainActor
protocol StravaConnectInteractor: GlobalInteractor {
    var stravaIsConnected: Bool { get }
    func stravaAuthenticate() async throws
}

extension CoreInteractor: StravaConnectInteractor { }
