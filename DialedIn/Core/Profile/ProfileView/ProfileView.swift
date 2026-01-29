//
//  ProfileView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
import SwiftfulRouting

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
                profileHeaderSection
                    .listSectionMargins(.top, 0)
//                profileHeaderView()
//                    .listSectionMargins(.top, 0)
                profilePhysicalMetricsView()
                profileGoalSection()
                profileNutritionPlanView()
                profilePreferencesView()
                profileMyTemplatesView()
            }
        }
        .navigationTitle("Profile")
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task {
            await presenter.getActiveGoal()

        }
    }

    private var profileHeaderSection: some View {
        Section {
            if let user = presenter.currentUser {
                HStack(spacing: 16) {
                    // Profile Image
                    CachedProfileImageView(
                        userId: user.userId,
                        imageUrl: user.profileImageUrl,
                        size: 60
                    )

                    // User Info
                    VStack(alignment: .leading, spacing: 6) {
                        Text(presenter.fullName)
                            .font(.title3)
                            .fontWeight(.semibold)

                        if let email = user.email {
                            Text(email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                    }
                    Spacer()

                    Image(systemName: "chevron.right")
                }
                .tappableBackground()
                .anyButton(.highlight) {
                    presenter.onProfileEditPressed()
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
            .badge(3)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
}

extension CoreBuilder {
    func profileView(router: AnyRouter) -> some View {
        ProfileView(
            presenter: ProfilePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            profileHeaderView: {
                self.profileHeaderView(router: router)
                    .any()
            },
            profilePhysicalMetricsView: {
                self.profilePhysicalMetricsView(router: router)
                    .any()
            },
            profileGoalSection: {
                self.profileGoalSection(router: router)
                    .any()
            },
            profileNutritionPlanView: {
                self.profileNutritionPlanView(router: router)
                    .any()
            },
            profilePreferencesView: {
                self.profilePreferencesView(router: router)
                    .any()
            },
            profileMyTemplatesView: {
                self.profileMyTemplatesView(router: router)
                    .any()
            }
        )
    }
}

extension CoreRouter {

    func showProfileView() {
        router.showScreen(.sheet) { router in
            builder.profileView(router: router)
        }
    }

    func showProfileViewZoom(transitionId: String?, namespace: Namespace.ID) {
        router.showScreenWithZoomTransition(
            .sheet,
            transitionID: transitionId,
            namespace: namespace) { router in
                builder.profileView(router: router)
            }
    }
}

// MARK: - Previews
#Preview("User Has Profile") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.profileView(router: router)
    }
    .previewEnvironment()
}

#Preview("User No Profile") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.profileView(router: router)
    }
    .previewEnvironment()
}
