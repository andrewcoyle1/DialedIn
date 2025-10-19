//
//  SplitViewContainer.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import Observation

struct SplitViewContainer: View {
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    @Environment(AppNavigationModel.self) private var appNavigation
    @State private var preferredColumn: NavigationSplitViewColumn = .sidebar

    @Environment(DetailNavigationModel.self) private var detail

    var body: some View {
        @Bindable var detail = detail
        @Bindable var appNavigation = appNavigation
        NavigationSplitView(columnVisibility: .constant(.all), preferredCompactColumn: $preferredColumn) {
            // Sidebar
            List(selection: $appNavigation.selectedSection) {
                SwiftUI.Section {
                    ForEach(AppSection.allCases) { section in
                        NavigationLink(value: section) {
                            Label(section.title, systemImage: section.systemImage)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let active = workoutSessionManager.activeSession, !workoutSessionManager.isTrackerPresented {
                    TabViewAccessory(active: active)
                        .padding()
                        .buttonStyle(.bordered)
                }
            }
            .frame(minWidth: 150)
        } content: {
            NavigationStack {
                if let selectedSection = appNavigation.selectedSection {
                    switch selectedSection {
                    case .dashboard:
                        NavigationOptions.dashboard.viewForPage()
                    case .training:
                        NavigationOptions.training.viewForPage()
                    case .nutrition:
                        NavigationOptions.nutrition.viewForPage()
                    case .profile:
                        NavigationOptions.profile.viewForPage()
                    }
                } else {
                    NavigationOptions.dashboard.viewForPage()
                }
            }
            .background(
                Color(uiColor: .systemGroupedBackground)
            )
        } detail: {
            NavigationStack(path: $detail.path) {
                detailPlaceholder
            }
            .navigationDestinationForCoreModule(path: $detail.path)
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: Binding(get: {
            workoutSessionManager.isTrackerPresented
        }, set: { newValue in
            workoutSessionManager.isTrackerPresented = newValue
        })) {
            if let session = workoutSessionManager.activeSession {
                WorkoutTrackerView(workoutSession: session)
            }
        }
        .task {
            // Load any active session from local storage when the SplitView appears
            if let active = try? workoutSessionManager.getActiveLocalWorkoutSession() {
                workoutSessionManager.activeSession = active
            }
        }
        .onChange(of: appNavigation.selectedSection) { _, _ in
            detail.clear()
        }
    }
}

#Preview {
    SplitViewContainer()
        .previewEnvironment()
}

private extension SplitViewContainer {
    var detailPlaceholder: some View {
        Text("Select an item to view details")
            .foregroundStyle(.secondary)
            .padding()
    }
}
