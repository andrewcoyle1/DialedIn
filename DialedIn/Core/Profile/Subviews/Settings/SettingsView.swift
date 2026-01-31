//
//  SettingsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/6/24.
//

import SwiftUI
import SwiftfulRouting

struct SettingsView: View {

    @State var presenter: SettingsPresenter

    var body: some View {
        List {
            accountSection
            purchaseSection
            dataManagementSection
            applicationSection
        }
        .navigationTitle("Settings")
        .onAppear {
            presenter.setAnonymousAccountStatus()
        }
        .screenAppearAnalytics(name: "Settings")
        .showModal(showModal: $presenter.showRatingsModal) {
            ratingsModal
        }
    }

    private var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying Dialed?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: { presenter.onEnjoyingAppYesPressed() },
            secondaryButtonTitle: "Not now",
            secondaryButtonAction: { presenter.onEnjoyingAppNoPressed() }
        )
    }
    private var accountSection: some View {
        Section {
            if presenter.isAnonymousUser {
                Text("Save & back-up account")
                    .anyButton(.highlight) {

                    }
            } else {
                Text("Sign out")
                    .anyButton(.highlight) {
                        presenter.onSignOutPressed()
                    }
            }
            
            Text("Delete account")
                .foregroundStyle(.red)
                .anyButton(.highlight) {
                    presenter.onDeleteAccountPressed()
                }
        } header: {
            Text("Account")
        }
    }
    
    private var purchaseSection: some View {
        Section {
            Button {
                presenter.navToManageSubscriptionView()
            } label: {
                Text("Account status: \(presenter.isPremium ? "PREMIUM" : "FREE")")
            }
            
        } header: {
            Text("Purchases")
        }
    }

    private var dataManagementSection: some View {
        Section {
            Group {
                CustomListCellView(
                    imageName: nil,
                    title: "Data Export",
                    subtitle: nil
                )
                .anyButton(.highlight) {

                }
                CustomListCellView(
                    imageName: nil,
                    title: "Data Visibility",
                    subtitle: nil
                )
                .anyButton(.highlight) {

                }
                CustomListCellView(
                    imageName: nil,
                    title: "Account & Data Deletion",
                    subtitle: nil
                )
                .anyButton(.highlight) {

                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Data Management")
        }
    }

    private var applicationSection: some View {
        Section {
            Button {
                presenter.onRatingsButtonPressed()
            } label: {
                Text("Rate us on the App Store")
            }

            HStack(spacing: 8) {
                Text("Version")
                Spacer(minLength: 0)
                Text(presenter.appVersion)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 8) {
                Text("Build Number")
                Spacer(minLength: 0)
                Text(presenter.appBuild)
                    .foregroundStyle(.secondary)
            }

            Button {
                presenter.onContactUsPressed()
            } label: {
                Text("Contact us")
            }
        } header: {
            Text("Application")
        } footer: {
            Text("Created by Andrew Coyle.\nLearn more at www.swiftful-thinking.com.")
                .baselineOffset(6)
        }
    }
}

fileprivate extension View {
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(uiColor: .systemBackground))
    }
}

extension CoreBuilder {
    func settingsView(router: AnyRouter) -> some View {
        SettingsView(
            presenter: SettingsPresenter(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            )
        )
    }
}

extension CoreRouter {
    func showSettingsView() {
        router.showScreen(.push) { router in
            builder.settingsView(router: router)
        }
    }
}

#Preview("No auth") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.settingsView(router: router)
    }
    .previewEnvironment()
}

#Preview("Anonymous") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.settingsView(router: router)
    }
    .previewEnvironment()
}
#Preview("Not anonymous") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.settingsView(router: router)
    }
    .previewEnvironment()
}

#Preview("Premium") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.settingsView(router: router)
    }
    .previewEnvironment()
}
