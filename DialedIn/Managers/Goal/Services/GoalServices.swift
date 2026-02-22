//
//  GoalServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

@MainActor
protocol GoalServices {
    var remote: RemoteGoalService { get }
    var local: LocalGoalService { get }
}
