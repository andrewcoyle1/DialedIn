//
//  GlobalRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI
import CustomRouting

@MainActor
protocol GlobalRouter {
    var router: Router { get }
}

extension GlobalRouter {
    
    func dismissScreen() {
        router.dismissScreen()
    }

    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: error.localizedDescription, buttons: nil)
    }

    func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, buttons: buttons)
    }

    func showSimpleAlert(title: String, subtitle: String?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, buttons: nil)
    }

    func showConfirmationDialog(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(.confirmationDialog, title: title, subtitle: subtitle, buttons: buttons)
    }
    
    func dismissModal() {
        router.dismissModal()
    }

}
