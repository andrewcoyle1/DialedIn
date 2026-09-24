//
//  AppDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI
import Firebase
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    var builder: CoreBuilder!

    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
    /// The Live Activity's way into the app (spec: docs/specs/live-activity.md §7.1).
    ///
    /// Held here because `LiveActivityIntentHandler.current` is weak on purpose, and the app
    /// delegate is the one object that lives exactly as long as the process. A background launch
    /// for an intent runs this method before any `perform()`, so the handler is always in place.
    private var liveActivityIntentHandler: AppLiveActivityIntentHandler?
    #endif

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        var config: BuildConfiguration
        
        #if MOCK
        config = .mock(scenario: .existingSignedIn)
        #elseif DEBUG
        config = .dev
        #else
        config = .prod
        #endif
        
        if Utilities.isUITesting {
            let isSignedIn = ProcessInfo.processInfo.arguments.contains("SIGNED_IN")
            config = .mock(scenario: isSignedIn ? .existingSignedIn : .newAnonymous)
        }
        
        config.configure()
        
        // Must be called AFTER configuring Firebase
        registerForRemotePushNotifications(application: application)

        let dependencies = Dependencies(config: config)
        self.dependencies = dependencies
        self.builder = CoreBuilder(interactor: CoreInteractor(container: dependencies.container))
        registerLiveActivityIntentHandler(container: dependencies.container)
        seedPushPayloadFromLaunchArguments()
        return true
    }
    
    /// Registered for every configuration, mock included, so the Mock scheme exercises the same
    /// path the device does.
    private func registerLiveActivityIntentHandler(container: DependencyContainer) {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        let handler = AppLiveActivityIntentHandler(
            workoutSessionManager: container.resolve(WorkoutSessionManager.self)!,
            hkWorkoutManager: container.resolve(HKWorkoutManager.self)!,
            liveActivityUpdater: container.resolve(LiveActivityManager.self)!,
            workoutSettingsManager: container.resolve(WorkoutSettingsManager.self)!,
            exerciseSettingsManager: container.resolve(ExerciseSettingsManager.self)!,
            exerciseModelManager: container.resolve(ExerciseModelManager.self)!,
            gymProfileManager: container.resolve(GymProfileManager.self)!,
            trainingProgramManager: container.resolve(TrainingProgramManager.self)!,
            userManager: container.resolve(UserManager.self)!,
            streakManager: container.resolve(StreakManager.self),
            stravaManager: container.resolve(StravaManager.self),
            logManager: container.resolve(LogManager.self)!
        )
        liveActivityIntentHandler = handler
        LiveActivityIntentHandler.current = handler
        #endif
    }

    /// `PUSH_PAYLOAD_JSON '{"type":"follow_request"}'` as launch arguments stands in for a push
    /// tapped to launch the app, which the simulator cannot deliver on its own.
    private func seedPushPayloadFromLaunchArguments() {
        #if MOCK || DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        guard
            let index = arguments.firstIndex(of: "PUSH_PAYLOAD_JSON"),
            arguments.indices.contains(index + 1),
            let data = arguments[index + 1].data(using: .utf8),
            let payload = try? JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any]
        else { return }
        storePendingDeepLink(DeepLink(pushUserInfo: payload))
        #endif
    }

    private func registerForRemotePushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        #if !MOCK
        // Only need to set Firebase Messaging if Firebase is configured
        Messaging.messaging().delegate = self
        #endif
        application.registerForRemoteNotifications()
    }

}

/// Firbase Cloud Messaging Docs: https://firebase.google.com/docs/cloud-messaging/ios/client
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        #if DEBUG
        print("🚨 didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
        #endif
    }
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // FCM puts the message's `data` keys at the top level of userInfo, beside `aps` — reading
        // only `aps` meant no tap ever carried a destination. Parsed here because userInfo is not
        // Sendable; `DeepLink` is.
        let deepLink = DeepLink(pushUserInfo: response.notification.request.content.userInfo)
        await storePendingDeepLink(deepLink)
    }

    /// Parks the destination on `PushManager` and tells a tab bar already on screen to take it. On a
    /// cold start nothing is listening yet; `logIn` and the tab bar's appear pick it up instead.
    private func storePendingDeepLink(_ deepLink: DeepLink?) {
        guard let deepLink else { return }
        dependencies?.container.resolve(PushManager.self)?.storePendingDeepLink(deepLink)
        NotificationCenter.default.post(name: .pushNotification, object: nil)
    }
}

extension AppDelegate: MessagingDelegate {
    
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        NotificationCenter.default.postFCMToken(token: fcmToken ?? "")
    }
}

enum MockScenario {
    case newAnonymous
    case existingSignedOut
    case existingSignedIn
}

enum BuildConfiguration {
    case mock(scenario: MockScenario), dev, prod
    
    func configure() {
        switch self {
        case .mock:
            break
        case .dev:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            #if targetEnvironment(simulator)
            AppCheck.setAppCheckProviderFactory(DebugAppCheckProviderFactory())
            #else
            let providerFactory = MyAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            #endif
            FirebaseApp.configure(options: options)
            Analytics.setAnalyticsCollectionEnabled(true)
            
        case .prod:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            let providerFactory = MyAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            FirebaseApp.configure(options: options)
            Analytics.setAnalyticsCollectionEnabled(true)
        }
    }
}
