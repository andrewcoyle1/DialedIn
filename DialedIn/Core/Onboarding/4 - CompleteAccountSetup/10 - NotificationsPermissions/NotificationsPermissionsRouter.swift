//
//  NotificationsPermissionsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol NotificationsPermissionsRouter: GlobalRouter {
    func showDevSettingsView()
    func showOnboardingHealthDataView()
    func showHealthDisclaimerView()
    func showNotificationsPermissionsModal(onConfirmPressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void) 
}

extension CoreRouter: NotificationsPermissionsRouter {
    func showNotificationsPermissionsModal(onConfirmPressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void) {
        router.showModal(
            transition: .opacity,
            backgroundColor: .black.opacity(0.3),
            dismissOnBackgroundTap: true,
            destination: {
                CustomModalView(
                    title: "Enable Push Notifications?",
                    subtitle: "We will send you reminders and updates",
                    primaryButtonTitle: "Enable",
                    primaryButtonAction: {
                        onConfirmPressed()
                    },
                    secondaryButtonTitle: "Cancel",
                    secondaryButtonAction: {
                        onCancelPressed()
                    }
                )
            }
        )
    }
}
