//
//  MockNutritionPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import Foundation

@MainActor
struct MockNutritionPersistence: LocalNutritionPersistence {
    
    var showError: Bool

    init(showError: Bool = false) {
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
}
