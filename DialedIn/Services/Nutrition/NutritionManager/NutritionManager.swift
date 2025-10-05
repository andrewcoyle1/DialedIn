//
//  NutritionManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

@MainActor
@Observable
class NutritionManager {
    
    private let local: LocalNutritionPersistence
    private let remote: RemoteNutritionService
    
    init(services: NutritionServices) {
        self.remote = services.remote
        self.local = services.local
    }
}
