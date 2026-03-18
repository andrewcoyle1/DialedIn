//
//  AppView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI
import SwiftfulUI

struct AppView<Content: View>: View {

    @State var presenter: AppPresenter

    @ViewBuilder var content: () -> Content

    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await presenter.checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            ),
            content: {
                content()
                    .onFirstAppear {
                        presenter.schedulePushNotifications()
                    }
                    .task {
                        await presenter.checkUserStatus()
                    }
                    .task {
                        try? await Task.sleep(for: .seconds(2))
                        await presenter.showATTPromptIfNeeded()
                    }
                    .onChange(of: presenter.auth?.uid) { _, newValue in
                        if newValue == nil || newValue?.isEmpty == true {
                            Task {
                                await presenter.checkUserStatus()
                            }
                        }
                    }
            }
        )
        .onNotificationReceived(name: .fcmToken) { notification in
            presenter.onFCMTokenRecieved(notification: notification)
        }
        .onNotificationReceived(name: .newActivityNotification) { notification in
            presenter.onNewActivityNotification(notification: notification)
        }
        .overlay(alignment: .top) {
            if let banner = presenter.activityBanner {
                ActivityNotificationBannerView(notification: banner)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring, value: presenter.activityBanner != nil)
                    .padding(.top, 8)
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }

    }
}

#Preview("AppView - Tabbar") {
    let container = DevPreview.shared.container()
    container.register(AppState.self, service: AppState(startingModuleId: Constants.tabBarModuleId))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder.appView()
}

#Preview("AppView - Onboarding") {
    let container = DevPreview.shared.container()
    let userSyncEngine = DocumentSyncEngine<UserModel>(
        remote: MockRemoteDocumentService(),
        managerKey: "user",
        enableLocalPersistence: true,
        logger: nil
    )
    let followingUsersSyncEngine = CollectionSyncEngine<UserModel>(
        remote: MockRemoteCollectionService(),
        managerKey: "followingUsers",
        enableLocalPersistence: true,
        logger: nil
    )
    let userQueryService = MockUserQueryService()
    container.register(UserManager.self, service: UserManager(queryService: userQueryService, userSyncEngine: userSyncEngine, followingUsersSyncEngine: followingUsersSyncEngine))
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(scenario: .newAnonymous)))
    container.register(AppState.self, service: AppState(startingModuleId: Constants.onboardingModuleId))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return builder.appView()
}

extension CoreBuilder {
    func appView() -> some View {
        AppView(
            presenter: AppPresenter(
                interactor: interactor
            ),
            content: {
                switch interactor.startingModuleId {
                case Constants.tabBarModuleId:
                    RouterView(id: Constants.tabBarModuleId, addNavigationStack: false, addModuleSupport: true) { _ in
                        coreModuleEntryView()
                    }
                default:
                    RouterView(id: Constants.onboardingModuleId, addNavigationStack: false, addModuleSupport: true) { _ in
                        onboardingModuleEntryView()
                    }
                }
            }
        )
    }
    
    func onboardingModuleEntryView() -> some View {
        onboardingFlow()
    }
    
    func coreModuleEntryView() -> some View {
        adaptiveMainView()
    }
}

extension CoreRouter {
    
    func switchToCoreModule() {
        router.showModule(.trailing, id: Constants.tabBarModuleId, onDismiss: nil) { _ in
            self.builder.coreModuleEntryView()
        }
    }
    
}

extension CoreRouter {
    
    func switchToOnboardingModule() {
        router.showModule(.leading, id: Constants.onboardingModuleId, onDismiss: nil) { _ in
            self.builder.onboardingModuleEntryView()
        }
    }
}
