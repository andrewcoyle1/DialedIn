//
//  SettingsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/6/24.
//

import SwiftUI

struct SettingsView: View {

    @State var presenter: SettingsPresenter

    var body: some View {
        List {
            accountSection
            purchaseSection
            nutritionSection
            applicationSection
        }
        .navigationTitle("Settings")
        .onAppear {
            presenter.setAnonymousAccountStatus()
        }
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
    }

    private var accountSection: some View {
        Section {
            if presenter.isAnonymousUser {
                Text("Save & back-up account")
                    .anyButton(.highlight) {
                        presenter.onSaveAccountPressed()
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

    // A "Data Management" section sat here: Data Export, Data Visibility and "Account & Data
    // Deletion", all three empty closures. Deletion was a duplicate — "Delete account" in the Account
    // section above already does it, and works. Export needs a format and a Cloud Function
    // (`functions/` has no export callable); Visibility needs a privacy model and matching Firestore
    // rules before a toggle would restrict anything. Both are in the plan's deferred table.
    //
    // It was also never rendered: `body` lists account, purchase, nutrition and application, so the
    // section had been orphaned at some point and the three dead rows were unreachable.

    private var nutritionSection: some View {
        Section {
            Button {
                presenter.onNutritionPlanPressed()
            } label: {
                Label("Nutrition Plan", systemImage: "fork.knife")
            }
        } header: {
            Text("Nutrition")
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
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.settingsView(router: router)
    }
    
}

#Preview("Anonymous") {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.settingsView(router: router)
    }
    
}
#Preview("Not anonymous") {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.settingsView(router: router)
    }
    
}

#Preview("Premium") {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.settingsView(router: router)
    }
    
}
