//
//  GlobalRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
protocol GlobalRouter {
    var router: AnyRouter { get }
}

extension GlobalRouter {
    
    /// Dismiss this screen and all screens in front of it.
    func dismissScreen() {
        router.dismissScreen()
    }

    /// Dismiss the closest .sheet or .fullScreenCover to this screen.
    func dismissEnvironment() {
        router.dismissEnvironment()
    }
    
    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: error.localizedDescription, buttons: { })
    }

    func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(
            .alert,
            title: title,
            subtitle: subtitle,
            buttons: {
                buttons?()
            }
        )
    }

    func showSimpleAlert(title: String, subtitle: String?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, buttons: { })
    }

    func showConfirmationDialog(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(
            .confirmationDialog,
            title: title,
            subtitle: subtitle,
            buttons: {
                buttons?()
            }
        )
    }
    
    func showLoadingModal() {
        router.showModal(
            transition: .opacity,
            backgroundColor: .black.opacity(0.3),
            destination: {
                ProgressView()
                    .tint(.white)
            }
        )
    }
    
    func dismissModal() {
        router.dismissModal()
    }
}
