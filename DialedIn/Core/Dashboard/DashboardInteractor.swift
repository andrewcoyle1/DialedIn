//
//  DashboardInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol DashboardInteractor {
    var userImageUrl: String? { get }
    var activeTests: ActiveABTests { get }
    var userId: String? { get }
    var weightHistory: [WeightEntry] { get }
    func trackEvent(event: LoggableEvent)
    func readAllLocalWeightEntries() throws -> [WeightEntry]
    func readAllRemoteWeightEntries(userId: String) async throws -> [WeightEntry]
}

extension CoreInteractor: DashboardInteractor { }
