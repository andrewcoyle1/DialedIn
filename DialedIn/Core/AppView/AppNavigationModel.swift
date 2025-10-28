//
//  AppNavigationModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import Observation

enum AppSection: String, Hashable, CaseIterable, Identifiable {
    case dashboard
    case training
    case nutrition
    case profile
    case search
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .training: return "Training"
        case .nutrition: return "Nutrition"
        case .profile: return "Profile"
        case .search: return "Search"
        }
    }
    
    var systemImage: String {
        switch self {
        case .dashboard: return "house"
        case .training: return "dumbbell"
        case .nutrition: return "carrot"
        case .profile: return "person.fill"
        case .search: return "magnifyingglass"
        }
    }
}

@Observable
final class AppNavigationModel {
    var selectedSection: AppSection? = .dashboard
}
