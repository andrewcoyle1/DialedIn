//
//  ProfilePhysicalMetricsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol ProfilePhysicalMetricsInteractor {
    var currentUser: UserModel? { get }
    var currentGoal: WeightGoal? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProfilePhysicalMetricsInteractor { }
