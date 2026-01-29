//
//  ProductionGoalServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionGoalServices: GoalServices {
    let remote: RemoteGoalService = ProductionRemoteGoalService()
    let local: LocalGoalService = ProductionLocalGoalService()
}
