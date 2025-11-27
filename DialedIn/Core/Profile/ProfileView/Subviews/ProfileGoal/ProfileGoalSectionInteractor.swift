//
//  ProfileGoalSectionInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol ProfileGoalSectionInteractor {
    var currentUser: UserModel? { get }
    var currentGoal: WeightGoal? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProfileGoalSectionInteractor { }
