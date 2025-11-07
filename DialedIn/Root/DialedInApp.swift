//
//  DialedInApp.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/08/2025.
//

import SwiftUI
import GoogleSignIn

struct DialedInApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppView(
                viewModel: AppViewModel(
                    interactor: CoreInteractor(
                        container: delegate.dependencies.container
                    )
                )
            )
            .environment(delegate.dependencies.container)
            .environment(delegate.dependencies.logManager)
            .onOpenURL { url in
                _ = GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
