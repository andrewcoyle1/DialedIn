//
//  ProfileViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProfileInteractor {
    var currentUser: UserModel? { get }
    var currentGoal: WeightGoal? { get }
    var currentDietPlan: DietPlan? { get }
    func getActiveGoal(userId: String) async throws -> WeightGoal?
}

extension CoreInteractor: ProfileInteractor { }

@Observable
@MainActor
class ProfileViewModel {
    private let interactor: ProfileInteractor
    
    private(set) var activeGoal: WeightGoal?
    
#if DEBUG || MOCK
    var showDebugView: Bool = false
#endif
    var showNotifications: Bool = false
    var showCreateProfileSheet: Bool = false
    var showSetGoalSheet: Bool = false
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var currentGoal: WeightGoal? {
        interactor.currentGoal
    }
    
    var currentDietPlan: DietPlan? {
        interactor.currentDietPlan
    }
    
    init(
        interactor: ProfileInteractor
    ) {
        self.interactor = interactor
    }
    
    func getActiveGoal() async {
        if let userId = self.currentUser?.userId {
            activeGoal = try? await interactor.getActiveGoal(userId: userId)
        }
    }
    
}
