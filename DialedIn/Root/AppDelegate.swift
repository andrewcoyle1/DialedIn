//
//  AppDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI
import Firebase
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    var builder: CoreBuilder!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        var config: BuildConfiguration
        
        #if MOCK
        config = .mock(isSignedIn: true)
        #elseif DEBUG
        config = .dev
        #else
        config = .prod
        #endif
        
        if ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
            let isSignedIn = ProcessInfo.processInfo.arguments.contains("SIGNED_IN")
            UserDefaults.showTabBarView = isSignedIn
            config = .mock(isSignedIn: isSignedIn)
        }
        
        config.configure()
        dependencies = Dependencies(config: config)
        builder = CoreBuilder(container: dependencies.container)
        return true
    }
    
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool), dev, prod
    
    func configure() {
        switch self {
        case .mock:
            // Mock build does not run Firebase
            break
        case .dev:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            let providerFactory = MyAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            FirebaseApp.configure(options: options)
            Analytics.setAnalyticsCollectionEnabled(true)
            
            // Configure Google Sign-In
            guard let clientId = options.clientID else { fatalError("No client ID found in Firebase options") }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        case .prod:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            let providerFactory = MyAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            FirebaseApp.configure(options: options)
            Analytics.setAnalyticsCollectionEnabled(true)
            
            // Configure Google Sign-In
            guard let clientId = options.clientID else { fatalError("No client ID found in Firebase options") }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        }
    }
}
