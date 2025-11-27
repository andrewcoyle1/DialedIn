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

    @State var presenter: ProfilePresenter

    @ViewBuilder var profileHeaderView: () -> AnyView
    @ViewBuilder var profilePhysicalMetricsView: () -> AnyView
    @ViewBuilder var profileGoalSection: () -> AnyView
    @ViewBuilder var profileNutritionPlanView: () -> AnyView
    @ViewBuilder var profilePreferencesView: () -> AnyView
    @ViewBuilder var profileMyTemplatesView: () -> AnyView

    var body: some View {
        List {
            if let user = presenter.currentUser,
               let firstName = user.firstName, !firstName.isEmpty {
                profileHeaderView()
                profilePhysicalMetricsView()
                profileGoalSection()
                profileNutritionPlanView()
                profilePreferencesView()
                profileMyTemplatesView()
            } else {
                createProfileSection
            }
        }
        .navigationTitle("Profile")
        .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .task {
            await presenter.getActiveGoal()

        }
    }

    var createProfileSection: some View {
        Section {
            Button {
                presenter.onCreateAccountPressed()
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
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.navToSettingsView()
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
