//
//  WatchAppView.swift
//  DialedInWatchApp
//
//  Created by AI Assistant on 25/10/2025.
//

import SwiftUI

struct WatchAppView: View {
    @State private var selectedTab: Tab = .workouts
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WorkoutListView()
                .tag(Tab.workouts)
            
            ActiveWorkoutView()
                .tag(Tab.activeWorkout)
            
            SettingsView()
                .tag(Tab.settings)
        }
        .tabViewStyle(.verticalPage)
    }
    
    enum Tab: String, CaseIterable {
        case workouts
        case activeWorkout
        case settings
    }
}

#Preview {
    WatchAppView()
}
