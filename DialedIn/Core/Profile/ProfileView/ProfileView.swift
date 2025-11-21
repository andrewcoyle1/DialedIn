//
//  ProfileView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
import CustomRouting

struct ProfileView: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var viewModel: ProfileViewModel

    @ViewBuilder var profileHeaderView: (ProfileHeaderViewDelegate) -> AnyView
    @ViewBuilder var profilePhysicalMetricsView: (ProfilePhysicalMetricsViewDelegate) -> AnyView
    @ViewBuilder var profileGoalSection: (ProfileGoalSectionDelegate) -> AnyView
    @ViewBuilder var profileNutritionPlanView: (ProfileNutritionPlanViewDelegate) -> AnyView
    @ViewBuilder var profilePreferencesView: (ProfilePreferencesViewDelegate) -> AnyView
    @ViewBuilder var profileMyTemplatesView: (ProfileMyTemplatesViewDelegate) -> AnyView
    @ViewBuilder var setGoalFlowView: () -> AnyView

    var body: some View {
        List {
            if let user = viewModel.currentUser,
               let firstName = user.firstName, !firstName.isEmpty {
                profileHeaderView(ProfileHeaderViewDelegate(path: .constant([])))
                profilePhysicalMetricsView(ProfilePhysicalMetricsViewDelegate(path: .constant([])))
                profileGoalSection(ProfileGoalSectionDelegate(path: .constant([])))
                profileNutritionPlanView(ProfileNutritionPlanViewDelegate(path: .constant([])))
                profilePreferencesView(ProfilePreferencesViewDelegate(path: .constant([])))
                profileMyTemplatesView(ProfileMyTemplatesViewDelegate(path: .constant([])))
            } else {
                createProfileSection
            }
        }
        .navigationTitle("Profile")
        .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.showSetGoalSheet) {
            setGoalFlowView()
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
                viewModel.onCreateAccountPressed()
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
                viewModel.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.navToSettingsView(path: .constant([]))
            } label: {
                Image(systemName: "gear")
            }
        }
    }
}

// MARK: - Previews
#Preview("User Has Profile") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.profileView(router: router)
    }
    .previewEnvironment()
}

#Preview("User No Profile") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.profileView(router: router)
    }
    .previewEnvironment()
}
