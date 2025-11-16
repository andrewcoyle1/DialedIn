//
//  ProfileView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct ProfileView: View {

    @Environment(CoreBuilder.self) private var builder
    @Environment(\.layoutMode) private var layoutMode

    @State var viewModel: ProfileViewModel

    @Binding var path: [TabBarPathOption]

    var body: some View {
        Group {
            if layoutMode == .tabBar {
                NavigationStack(path: $path) {
                    contentView
                }
                .navDestinationForTabBarModule(path: $path)
            } else {
                contentView
            }
        }
    }
    
    private var contentView: some View {
        List {
            if let user = viewModel.currentUser,
               let firstName = user.firstName, !firstName.isEmpty {
                builder.profileHeaderView(delegate: ProfileHeaderViewDelegate(path: $path))
                builder.profilePhysicalMetricsView(delegate: ProfilePhysicalMetricsViewDelegate(path: $path))
                builder.profileGoalSection(delegate: ProfileGoalSectionDelegate(path: $path))
                builder.profileNutritionPlanView(delegate: ProfileNutritionPlanViewDelegate(path: $path))
                builder.profilePreferencesView(delegate: ProfilePreferencesViewDelegate(path: $path))
                builder.profileMyTemplatesView(delegate: ProfileMyTemplatesViewDelegate(path: $path))
            } else {
                createProfileSection
            }
        }
        .navigationTitle("Profile")
        .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.large)
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView, content: {
            builder.devSettingsView()
        })
        #endif
        .sheet(isPresented: $viewModel.showCreateProfileSheet) {
            builder.createAccountView()
                .presentationDetents([
                    .fraction(0.4)
                ])
        }
        .sheet(isPresented: $viewModel.showNotifications) {
            builder.notificationsView()
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
            Button {
                viewModel.navToSettingsView(path: $path)
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
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.profileView(path: $path)
    .previewEnvironment()
}

#Preview("User No Profile") {
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.profileView(path: $path)
    .previewEnvironment()
}
