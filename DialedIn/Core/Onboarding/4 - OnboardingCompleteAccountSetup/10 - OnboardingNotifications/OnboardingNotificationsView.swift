//
//  OnboardingNotificationsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingNotificationsView: View {

    @State var presenter: OnboardingNotificationsPresenter

    var body: some View {
        List {
            justificationSection

            reassuranceSection
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        #if !DEBUG && !MOCK
        .navigationBarBackButtonHidden(true)
        #endif
        .toolbar {
            toolbarContent
        }
        .screenAppearAnalytics(name: "OnboardingNotifications")
        .showModal(showModal: $presenter.showEnablePushNotificationsModal) {
            pushNotificationModal
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
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.onEnableNotificationsPressed()
            } label: {
                Text("Enable notifications")
                    .padding()
            }
            .buttonStyle(.glassProminent)
        }
        ToolbarSpacer(.fixed)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.onSkipForNowPressed()
            } label: {
                Image(systemName: "chevron.right")
            }
        }
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

    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable Push Notifications?",
            subtitle: "We will send you reminders and updates",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                presenter.onEnablePushNotificationsPressed()
            },
            secondaryButtonTitle: "Cancel",
            secondaryButtonAction: {
                presenter.onCancelPushNotificationsPressed()
            }
        )
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingNotificationsView(router: router)
    }
    .previewEnvironment()
}
