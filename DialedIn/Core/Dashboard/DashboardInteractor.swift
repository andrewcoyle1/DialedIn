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
    var measurementHistory: [BodyMeasurementEntry] { get }
    var auth: UserAuthInfo? { get }
    func trackEvent(event: LoggableEvent)
    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry]
    func readAllRemoteWeightEntries(userId: String) async throws -> [BodyMeasurementEntry]
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel]
}

extension CoreInteractor: DashboardInteractor { }
