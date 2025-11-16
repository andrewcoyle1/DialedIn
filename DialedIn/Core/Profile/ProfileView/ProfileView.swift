//
//  ProfileView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct ProfileViewDelegate {
    var path: Binding<[TabBarPathOption]>
}

struct ProfileView: View {

    @Environment(CoreBuilder.self) private var builder
    @Environment(\.layoutMode) private var layoutMode

    @State var viewModel: ProfileViewModel

    var delegate: ProfileViewDelegate

    var body: some View {
        Group {
            if layoutMode == .tabBar {
                NavigationStack(path: delegate.path) {
                    contentView
                }
                .navDestinationForTabBarModule(path: delegate.path)
            } else {
                contentView
            }
        }
    }
    
    private var contentView: some View {
        List {
            if let user = viewModel.currentUser,
               let firstName = user.firstName, !firstName.isEmpty {
                builder.profileHeaderView(delegate: ProfileHeaderViewDelegate(path: delegate.path))
                builder.profilePhysicalMetricsView(delegate: ProfilePhysicalMetricsViewDelegate(path: delegate.path))
                builder.profileGoalSection(delegate: ProfileGoalSectionDelegate(path: delegate.path))
                builder.profileNutritionPlanView(delegate: ProfileNutritionPlanViewDelegate(path: delegate.path))
                builder.profilePreferencesView(delegate: ProfilePreferencesViewDelegate(path: delegate.path))
                builder.profileMyTemplatesView(delegate: ProfileMyTemplatesViewDelegate(path: delegate.path))
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
                viewModel.navToSettingsView(path: delegate.path)
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
    builder.profileView(delegate: ProfileViewDelegate(path: $path))
    .previewEnvironment()
}

#Preview("User No Profile") {
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.profileView(delegate: ProfileViewDelegate(path: $path))
    .previewEnvironment()
}
