//
//  TabBarView.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI

struct TabBarView: View {
    
    private enum Section: String, CaseIterable, Identifiable {
        case dashboard
        case exercises
        case nutrition
        case profile
        
        var id: Self { self }
        
        var title: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .exercises: return "Exercises"
            case .nutrition: return "Nutrition"
            case .profile: return "Profile"
            }
        }
        
        var systemImage: String {
            switch self {
            case .dashboard: return "house"
            case .exercises: return "dumbbell"
            case .nutrition: return "carrot"
            case .profile: return "person.fill"
            }
        }
    }
    
    @State private var selectedSection: Section? = .dashboard
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            
            TrainingView()
                .tabItem {
                    Label("Exercises", systemImage: "dumbbell")
                }
            
            NutritionView()
                .tabItem {
                    Label("Nutrition", systemImage: "carrot")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tabViewStyle(.sidebarAdaptable)
        .defaultAdaptableTabBarPlacement(.sidebar)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    TabBarView()
        .previewEnvironment()
}
