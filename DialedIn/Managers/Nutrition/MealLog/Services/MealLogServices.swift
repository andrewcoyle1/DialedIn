//
//  MealLogServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

@MainActor
protocol MealLogServices {
    var remote: RemoteMealLogService { get }
    var local: LocalMealLogPersistence { get }
}
