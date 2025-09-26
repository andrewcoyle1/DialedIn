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
    
    private var shouldUseSplitView: Bool {
        #if os(macOS)
        return true
        #elseif targetEnvironment(macCatalyst)
        return true
        #else
        return UIDevice.current.userInterfaceIdiom == .pad
        #endif
    }
        
    var body: some View {
                Group {
                        if shouldUseSplitView {
                                NavigationSplitView {
                                        List(Section.allCases, selection: $selectedSection) { section in
                                                Label(section.title, systemImage: section.systemImage)
                                                        .tag(section)
                                        }
                                        .navigationTitle("Dialed In")
                                } detail: {
                                        switch selectedSection ?? .dashboard {
                                        case .dashboard:
                                                DashboardView()
                                        case .exercises:
                                                TrainingView()
                                        case .nutrition:
                                                Text("Nutrition")
                                        case .profile:
                                                ProfileView()
                                        }
                                }
                        } else {
                                TabView {
                                        DashboardView()
                                                .tabItem {
                                                        Label("Dashboard", systemImage: "house")
                                                }
                                        
                                        TrainingView()
                                                .tabItem {
                                                        Label("Exercises", systemImage: "dumbbell")
                                                }
                                        
                                        Text("Nutrition")
                                                .tabItem {
                                                        Label("Nutrition", systemImage: "carrot")
                                                }
                                        
                                        ProfileView()
                                                .tabItem {
                                                        Label("Profile", systemImage: "person.fill")
                                                }
                                }
                        }
                }
        
    }
}

#Preview {
    TabBarView()
        .previewEnvironment()
}
