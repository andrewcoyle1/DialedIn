//
//  TabBarOption.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/11/2025.
//

import Foundation

enum TabBarOption: Equatable, Hashable, CaseIterable, Identifiable {
    case dashboard
    case nutrition
    case training
    case profile
    case search
    
    static let mainPages: [TabBarOption] = [.dashboard, .nutrition, .training, .profile]
    var id: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .nutrition: return "Nutrition"
        case .training: return "Training"
        case .profile: return "Profile"
        case .search: return "Search"
        }
    }
    
    var name: LocalizedStringResource {
        switch self {
        case .dashboard: LocalizedStringResource("Dashboard", comment: "Title for the Dashboard tab, shown in the sidebar.")
        case .nutrition: LocalizedStringResource("Nutrition", comment: "Title for the Nutrition tab, shown in the sidebar.")
        case .training: LocalizedStringResource("Training", comment: "Title for the Training tab, shown in the sidebar.")
        case .profile: LocalizedStringResource("Profile", comment: "Title for the Profile tab, shown in the sidebar.")
        case .search: LocalizedStringResource("Search", comment: "Title for the Search tab, shown in the sidebar.")
        }
    }
    
    var symbolName: String {
        switch self {
        case .dashboard: "house"
        case .nutrition: "dumbbell"
        case .training: "carrot"
        case .profile: "person.fill"
        case .search: "magnifyingglass"
        }
    }
}
