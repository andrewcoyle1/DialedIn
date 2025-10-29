//
//  RemoteNutritionService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

protocol NutritionServices {
    var remote: RemoteNutritionService { get }
    var local: LocalNutritionPersistence { get }
}
