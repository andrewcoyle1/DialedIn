//
//  DialedInApp.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/08/2025.
//

import SwiftUI
import SwiftfulUtilities
import Firebase
import FirebaseCore
import FirebaseAnalytics
import FirebaseAppCheck
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

struct TestingApp: App {
    
    @State var isLoading = false
    
    var body: some Scene {
        WindowGroup {
            VStack {
                Text("Testing")
                HStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 10, height: 10)
                        .scaleEffect(isLoading ? 1.5 : 0.5)
                        .animation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true), value: isLoading)
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 10, height: 10)
                        .scaleEffect(isLoading ? 1.5 : 0.5)
                        .animation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true).delay(0.1), value: isLoading)
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 10, height: 10)
                        .scaleEffect(isLoading ? 1.5 : 0.5)
                        .animation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true).delay(0.2), value: isLoading)
                }
            }
            .onAppear {
                isLoading = true
            }
        }
    }
}

struct DialedInApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: delegate.dependencies.container)))
                .environment(delegate.dependencies.container)
                .environment(delegate.dependencies.logManager)
                .environment(delegate.dependencies.detailNavigationModel)
                .onOpenURL { url in
                    _ = GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
