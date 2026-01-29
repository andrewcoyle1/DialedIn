//
//  DialedInApp.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/08/2025.
//

import SwiftUI
import SwiftfulUtilities
import GoogleSignIn

@main
struct AppEntryPoint {

    static func main() {
        if SwiftfulUtilities.Utilities.isUnitTesting {
            TestingApp.main()
        } else {
            DialedInApp.main()
        }
    }
}

struct DialedInApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
                delegate.builder.build()
            .environment(delegate.dependencies.logManager)
            .onOpenURL { url in
                _ = GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
