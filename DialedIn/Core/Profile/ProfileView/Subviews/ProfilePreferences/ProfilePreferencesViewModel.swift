//
//  ProfilePreferencesViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProfilePreferencesInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: ProfilePreferencesInteractor { }

@Observable
@MainActor
class ProfilePreferencesViewModel {
    private let interactor: ProfilePreferencesInteractor
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: ProfilePreferencesInteractor
    ) {
        self.interactor = interactor
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
