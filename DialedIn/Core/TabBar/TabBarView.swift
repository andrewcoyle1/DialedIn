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
            case .exercises: return "Training"
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
    
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    @State private var selectedSection: Section? = .dashboard
    @State private var presentTracker: Bool = false
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            
            TrainingView()
                .tabItem {
                    Label("Training", systemImage: "dumbbell")
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
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            if let active = workoutSessionManager.activeSession, !workoutSessionManager.isTrackerPresented {
                TabViewAccessory(active: active)
            }
        }
        .fullScreenCover(isPresented: Binding(get: {
            workoutSessionManager.isTrackerPresented
        }, set: { newValue in
            workoutSessionManager.isTrackerPresented = newValue
        })) {
            if let session = workoutSessionManager.activeSession {
                WorkoutTrackerView(workoutSession: session)
            }
        }
        .task {
            // Load any active session from local storage when the TabBar appears
            if let active = try? workoutSessionManager.getActiveLocalWorkoutSession() {
                workoutSessionManager.activeSession = active
            }
        }
    }
}

#Preview("Has No Active Session") {
    TabBarView()
        .environment(WorkoutSessionManager(services: MockWorkoutSessionServices(hasActiveSession: false)))
        .previewEnvironment()
}

#Preview("Has Active Session") {
    TabBarView()
        .environment(WorkoutSessionManager(services: MockWorkoutSessionServices(hasActiveSession: true)))
        .previewEnvironment()
}
