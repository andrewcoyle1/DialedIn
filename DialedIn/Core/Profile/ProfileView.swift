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
                .anyButton {
                    presenter.onProfileEditPressed()
                }
            }
        }
    }
    
    private var generalSection: some View {
        Section {
            Group {
                Label("Subscription", systemImage: "tag")
                //                CustomListCellView(
                //                    sfSymbolName: "tag",
                //                    title: "Subscription"
                //                )
                    .anyButton(.highlight) {
                        presenter.onSubscriptionPressed()
                    }
                Label("Integrations", systemImage: "app.connected.to.app.below.fill")
                //                CustomListCellView(
                //                    sfSymbolName: "app.connected.to.app.below.fill",
                //                    title: "Integrations"
                //                )
                    .anyButton {
                        presenter.onIntegrationsPressed()
                    }
                Label("Units", systemImage: "base.unit")
                //                CustomListCellView(
                //                    sfSymbolName: "base.unit",
                //                    title: "Units"
                //                )
                    .anyButton {
                        presenter.onUnitsPressed()
                    }
                Label("Dashboard", systemImage: "house")
                //                CustomListCellView(
                //                    sfSymbolName: "house",
                //                    title: "Dashboard"
                //                )
                    .anyButton {
                        presenter.onCustomiseDashboardPressed()
                    }
                Label("Siri", systemImage: "siri")
                //                CustomListCellView(
                //                    sfSymbolName: "siri",
                //                    title: "Siri"
                //                )
                    .anyButton {
                        presenter.onSiriPressed()
                    }
                Label("Shortcuts", systemImage: "bolt")
                //                CustomListCellView(
                //                    sfSymbolName: "bolt",
                //                    title: "Shortcuts"
                //                )
                    .anyButton {
                        presenter.onShortcutsPressed()
                    }
                
            }
            .foregroundStyle(.primary)
            //            .removeListRowFormatting()
        } header: {
            Text("General")
        }
    }
    
    private var nutritionSettingsSection: some View {
        Section {
            Group {
                Label("Food Log", systemImage: "carrot")
                //                CustomListCellView(
                //                    sfSymbolName: "carrot",
                //                    title: "Food Log"
                //                )
                    .anyButton {
                        presenter.onFoodLogSettingsPressed()
                    }
                Label("Expenditure", systemImage: "flame")
                //                CustomListCellView(
                //                    sfSymbolName: "flame",
                //                    title: "Expenditure"
                //                )
                    .anyButton {
                        presenter.onExpenditureSettingsPressed()
                    }
                Label("Strategy", systemImage: "map")
                //                CustomListCellView(
                //                    sfSymbolName: "map",
                //                    title: "Strategy"
                //                )
                    .anyButton {
                        presenter.onStrategySettingsPressed()
                    }
            }
            .foregroundStyle(.primary)
            //            .removeListRowFormatting()
        } header: {
            Text("Nutrition Settings")
        }
    }
    
    private var trainingSettingsSection: some View {
        Section {
            Group {
                Label("Gym Profiles", systemImage: "building")
                //                CustomListCellView(
                //                    sfSymbolName: "building",
                //                    title: "Gym Profiles"
                //                )
                    .anyButton {
                        presenter.onGymProfilesPressed()
                    }
                Label("Exercises", systemImage: "list.bullet")
                //                CustomListCellView(
                //                    sfSymbolName: "list.bullet",
                //                    title: "Exercises"
                //                )
                    .anyButton {
                        presenter.onExerciseLibraryPressed()
                    }
                Label("Workout Settings", systemImage: "dumbbell")
                //                CustomListCellView(
                //                    sfSymbolName: "dumbbell",
                //                    title: "Workout Settings"
                //                )
                    .anyButton {
                        presenter.onWorkoutSettingsPressed()
                    }
            }
            .foregroundStyle(.primary)
            //            .removeListRowFormatting()
        } header: {
            Text("Training Settings")
        }
    }
    
    private var communityAndSupportSection: some View {
        Section {
            Group {
                Label("Knowledge Base", systemImage: "book.closed")
                //                CustomListCellView(
                //                    sfSymbolName: "book.closed",
                //                    title: "Knowledge Base"
                //                )
                    .anyButton {
                        
                    }
                Label("Roadmap", systemImage: "map")
                //                CustomListCellView(
                //                    sfSymbolName: "map",
                //                    title: "Roadmap"
                //                )
                    .anyButton {
                        
                    }
                Label("Support", systemImage: "questionmark.circle")
                //                CustomListCellView(
                //                    sfSymbolName: "questionmark.circle",
                //                    title: "Support"
                //                )
                    .anyButton {
                        
                    }
                Label("Rate us on the app store", systemImage: "star")
                //                CustomListCellView(
                //                    sfSymbolName: "star",
                //                    title: "Rate us on the app store"
                //                )
                    .anyButton {
                        presenter.onRatingsButtonPressed()
                    }
            }
            .foregroundStyle(.primary)
            //            .removeListRowFormatting()
        } header: {
            Text("Community & Support")
        }
    }
    
    private var otherSection: some View {
        Section {
            Group {
                Label("Legal", systemImage: "book")
                //                CustomListCellView(
                //                    sfSymbolName: "book",
                //                    title: "Legal"
                //                )
                    .anyButton(.highlight) {
                        presenter.onLegalPressed()
                    }
                Label("App Icon", systemImage: "app.grid")
                //                CustomListCellView(
                //                    sfSymbolName: "app.grid",
                //                    title: "App Icon"
                //                )
                    .anyButton(.highlight) {
                        presenter.onAppIconPressed()
                    }
                Label("Tutorials", systemImage: "book")
                //                CustomListCellView(
                //                    sfSymbolName: "book",
                //                    title: "Tutorials"
                //                )
                    .anyButton(.highlight) {
                        presenter.onTutorialPressed()
                    }
                Label("About", systemImage: "info.circle")
                //                CustomListCellView(
                //                    sfSymbolName: "info.circle",
                //                    title: "About"
                //                )
                    .anyButton(.highlight) {
                        presenter.onAboutPressed()
                    }
            }
            .foregroundStyle(.primary)
            //            .removeListRowFormatting()
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
