//
//  DialedInApp.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/08/2025.
//

import SwiftUI
import GoogleSignIn

@main
struct AppEntryPoint {

    /// Entry point is either (1) empty build for Unit Testing or (2) actual app.
    static func main() {
        if Utilities.isUnitTesting {
            AppViewForUnitTesting.main()
        } else {
            DialedInApp.main()
        }
    }
}

struct DialedInApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            if Utilities.isUITesting {
                AppViewForUITesting(container: delegate.dependencies.container)
            } else {
                delegate.builder.build()
            }
        }
    }
}
