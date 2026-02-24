//
//  NotificationsPermissionsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct NotificationsPermissionsView: View {

    @State var presenter: NotificationsPermissionsPresenter

    var body: some View {
        List {
            justificationSection

            reassuranceSection
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            toolbarContent
        }
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button {
                    presenter.onEnableNotificationsPressed()
                } label: {
                    Text("Enable notifications")
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)

                Button {
                    presenter.onSkipForNowPressed()
                } label: {
                    Text("Skip for now")
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)

            }
            .padding(.horizontal)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
    }

    private var justificationSection: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "bell.badge.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Stay Informed & Motivated")
                        .font(.headline)
                    Text("Enable notifications to receive reminders for workouts, nutrition tracking, and important updates. Stay on track and never miss a beat in your fitness journey.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Why Enable Notifications?")
        }
    }
    
    private var reassuranceSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Label("You can change your notification preferences at any time in Settings.", systemImage: "gearshape")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Label("We respect your privacy. Notifications are only used to help you reach your goals and are never shared.", systemImage: "lock.shield")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Good to Know")
        }
    }
    
    private var buttonSection: some View {
        VStack(spacing: 12) {
            Button {
                presenter.onEnableNotificationsPressed()
            } label: {
                Text("Enable notifications")
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .buttonStyle(.glassProminent)

            Button {
                presenter.onSkipForNowPressed()
            } label: {
                Text("Not now")
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
    }
}

extension CoreBuilder {
    func onboardingNotificationsView(router: AnyRouter) -> some View {
        NotificationsPermissionsView(
            presenter: NotificationsPermissionsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showNotificationsPermissionsView() {
        router.showScreen(.push) { router in
            builder.onboardingNotificationsView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingNotificationsView(router: router)
    }
    
}
