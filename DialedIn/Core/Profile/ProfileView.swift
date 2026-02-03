//
//  ProfileView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct ProfileView: View {

    @State var presenter: ProfilePresenter

    var body: some View {
        List {
            if let user = presenter.currentUser,
               let firstName = user.firstName, !firstName.isEmpty {
                profileHeaderSection
                    .listSectionMargins(.top, 0)

                generalSection
                nutritionSettingsSection
                trainingSettingsSection

                communityAndSupportSection

                otherSection
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

    private var generalSection: some View {
        Section {
            Group {
                CustomListCellView(
                    sfSymbolName: "tag",
                    title: "Subscription"
                )
                .anyButton(.highlight) {
                    presenter.onSubscriptionPressed()
                }
                CustomListCellView(
                    sfSymbolName: "app.connected.to.app.below.fill",
                    title: "Integrations"
                )
                .anyButton(.highlight) {
                    presenter.onIntegrationsPressed()
                }
                CustomListCellView(
                    sfSymbolName: "base.unit",
                    title: "Units"
                )
                .anyButton(.highlight) {
                    presenter.onUnitsPressed()
                }
                CustomListCellView(
                    sfSymbolName: "house",
                    title: "Dashboard"
                )
                .anyButton(.highlight) {
                    presenter.onCustomiseDashboardPressed() 
                }
                CustomListCellView(
                    sfSymbolName: "siri",
                    title: "Siri"
                )
                .anyButton(.highlight) {
                    presenter.onSiriPressed()
                }
                CustomListCellView(
                    sfSymbolName: "bolt",
                    title: "Shortcuts"
                )
                .anyButton(.highlight) {
                    presenter.onShortcutsPressed()
                }

            }
            .removeListRowFormatting()
        } header: {
            Text("General")
        }
    }

    private var nutritionSettingsSection: some View {
        Section {
            Group {
                CustomListCellView(
                    sfSymbolName: "carrot",
                    title: "Food Log"
                )
                .anyButton(.highlight) {
                    presenter.onFoodLogSettingsPressed()
                }
                CustomListCellView(
                    sfSymbolName: "flame",
                    title: "Expenditure"
                )
                .anyButton(.highlight) {
                    presenter.onExpenditureSettingsPressed()
                }
                CustomListCellView(
                    sfSymbolName: "map",
                    title: "Strategy"
                )
                .anyButton(.highlight) {
                    presenter.onStrategySettingsPressed()
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Nutrition Settings")
        }
    }

    private var trainingSettingsSection: some View {
        Section {
            Group {
                CustomListCellView(
                    sfSymbolName: "building",
                    title: "Gym Profiles"
                )
                .anyButton(.highlight) {
                    presenter.onGymProfilesPressed()
                }
                CustomListCellView(
                    sfSymbolName: "list.bullet",
                    title: "Exercises"
                )
                .anyButton(.highlight) {
                    presenter.onExerciseLibraryPressed()
                }
                CustomListCellView(
                    sfSymbolName: "dumbbell",
                    title: "Workout Settings"
                )
                .anyButton(.highlight) {
                    presenter.onWorkoutSettingsPressed()
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Training Settings")
        }
    }

    private var communityAndSupportSection: some View {
        Section {
            Group {
                CustomListCellView(
                    sfSymbolName: "book.closed",
                    title: "Knowledge Base"
                )
                .anyButton(.highlight) {

                }
                CustomListCellView(
                    sfSymbolName: "map",
                    title: "Roadmap"
                )
                .anyButton(.highlight) {

                }
                CustomListCellView(
                    sfSymbolName: "questionmark.circle",
                    title: "Support"
                )
                .anyButton(.highlight) {

                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Community & Support")
        }
    }

    private var otherSection: some View {
        Section {
            Group {
                CustomListCellView(
                    sfSymbolName: "book",
                    title: "Legal"
                )
                .anyButton(.highlight) {
                    presenter.onLegalPressed()
                }
                CustomListCellView(
                    sfSymbolName: "app.grid",
                    title: "App Icon"
                )
                .anyButton(.highlight) {
                    presenter.onAppIconPressed()
                }
                CustomListCellView(
                    sfSymbolName: "book",
                    title: "Tutorials"
                )
                .anyButton(.highlight) {
                    presenter.onTutorialPressed()
                }
                CustomListCellView(
                    sfSymbolName: "info.circle",
                    title: "About"
                )
                .anyButton(.highlight) {
                    presenter.onAboutPressed()
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Other")
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
            presenter: ProfilePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
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
    let container = DevPreview.shared.container()

    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    let builder = CoreBuilder(container: container)
    return RouterView { router in
        builder.profileView(router: router)
    }
    .previewEnvironment()
}
