//
//  ProfileView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct ProfileView: View {
    @Environment(DependencyContainer.self) var container
    @Environment(\.layoutMode) private var layoutMode
    
    @State var viewModel: ProfileViewModel
    
    var body: some View {
        Group {
            if layoutMode == .tabBar {
                NavigationStack {
                    contentView
                }
            } else {
                contentView
            }
        }
    }
    
    private var contentView: some View {
        List {
            if let user = viewModel.currentUser,
               let firstName = user.firstName, !firstName.isEmpty {
                ProfileHeaderView(viewModel: ProfileHeaderViewModel(container: container))
                ProfilePhysicalMetricsView(viewModel: ProfilePhysicalMetricsViewModel(container: container))
                ProfileGoalSection(viewModel: ProfileGoalSectionViewModel(container: container))
                ProfileNutritionPlanView(viewModel: ProfileNutritionPlanViewModel(container: container))
                ProfilePreferencesView(viewModel: ProfilePreferencesViewModel(container: container))
                ProfileMyTemplatesView(viewModel: ProfileMyTemplatesViewModel(container: container))
            } else {
                createProfileSection
            }
        }
        .navigationTitle("Profile")
        .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.large)
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView, content: {
            DevSettingsView(viewModel: DevSettingsViewModel(container: container))
        })
        #endif
        .sheet(isPresented: $viewModel.showCreateProfileSheet) {
            CreateAccountView(viewModel: CreateAccountViewModel(container: container))
                .presentationDetents([
                    .fraction(0.4)
                ])
        }
        .sheet(isPresented: $viewModel.showNotifications) {
            NotificationsView()
        }
        .sheet(isPresented: $viewModel.showSetGoalSheet) {
            SetGoalFlowView()
        }
        .toolbar {
            toolbarContent
        }
        .task {
            await viewModel.getActiveGoal()
            
        }
    }
    
    var createProfileSection: some View {
        Section {
            Button {
                viewModel.showCreateProfileSheet = true
            } label: {
                CustomListCellView(
                    imageName: nil,
                    title: "Create your profile",
                    subtitle: "Tap to get started",
                    isSelected: true,
                    iconName: "person.circle",
                    iconSize: CGFloat(32)
                )
            }
            .removeListRowFormatting()
        } header: {
            Text("Profile")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarLeading) {
            Button {
                onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink {
                SettingsView(viewModel: SettingsViewModel(container: container))
            } label: {
                Image(systemName: "gear")
            }
        }
    }
    
    private func onNotificationsPressed() {
        viewModel.showNotifications = true
    }
}

// MARK: - Previews
#Preview("User Has Profile") {
    return ProfileView(viewModel: ProfileViewModel(container: DevPreview.shared.container))
        .previewEnvironment()
}

#Preview("User No Profile") {
    ProfileView(viewModel: ProfileViewModel(container: DevPreview.shared.container))
        .previewEnvironment()
}
