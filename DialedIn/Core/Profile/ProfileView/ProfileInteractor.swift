//
//  ProfileInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol ProfileInteractor {
    var currentUser: UserModel? { get }
    var currentGoal: WeightGoal? { get }
    var currentDietPlan: DietPlan? { get }
    func getActiveGoal(userId: String) async throws -> WeightGoal?
    func trackEvent(event: LoggableEvent)
    func updateAppState(showTabBarView: Bool)
}

extension CoreInteractor: ProfileInteractor { }
