//
//  ProfilePreferencesViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProfilePreferencesViewModel {
    private let userManager: UserManager
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    init(
        container: DependencyContainer
    ) {
        self.userManager = container.resolve(UserManager.self)!
    }
    
    func formatUnitPreferences(length: LengthUnitPreference?, weight: WeightUnitPreference?) -> String {
        let lengthStr = length == .centimeters ? "Metric" : "Imperial"
        let weightStr = weight == .kilograms ? "Metric" : "Imperial"
        
        if lengthStr == weightStr {
            return lengthStr
        } else {
            return "Mixed"
        }
    }
}
