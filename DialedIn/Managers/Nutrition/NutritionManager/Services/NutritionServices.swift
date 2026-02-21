//
//  RemoteNutritionService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

@MainActor
protocol NutritionServices {
    var remote: RemoteNutritionService { get }
    var local: LocalNutritionPersistence { get }
}
