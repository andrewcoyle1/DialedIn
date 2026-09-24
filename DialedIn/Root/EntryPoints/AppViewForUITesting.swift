//
//  AppViewForUITesting.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/01/2026.
//

import SwiftUI

/// The root under `UI_TESTING`. A `STARTSCREEN_*` launch argument opens one flow directly on
/// its own router, signed in to the mock scenario the way `AppView` would be, so a UI test does
/// not have to walk the tab bar to reach it.
struct AppViewForUITesting: View {
    
    var container: DependencyContainer
    
    private var interactor: CoreInteractor {
        CoreInteractor(container: container)
    }

    private var builder: CoreBuilder {
        CoreBuilder(interactor: interactor)
    }
    
    private func processInfoContains(_ value: String) -> Bool {
        ProcessInfo.processInfo.arguments.contains(value)
    }

    var body: some View {
        if processInfoContains("STARTSCREEN_CREATE_EXERCISE") {
            startScreen { builder.createExerciseView(router: $0) }
        } else if processInfoContains("STARTSCREEN_CREATE_WORKOUT") {
            startScreen { builder.createWorkoutView(router: $0, delegate: CreateWorkoutDelegate()) }
        } else if processInfoContains("STARTSCREEN_CREATE_PROGRAM") {
            startScreen { builder.createProgramView(router: $0, delegate: CreateProgramDelegate()) }
        } else if processInfoContains("STARTSCREEN_SOCIAL_PROFILE") {
            startScreen { builder.socialProfileView(router: $0, delegate: SocialProfileDelegate(user: UserModel.mocks[2])) }
        } else if processInfoContains("STARTSCREEN_COMMENTS") {
            // The shipped mock comments all sit on "session-1".
            let session = WorkoutSessionModel.mocks.first { $0.id == "session-1" } ?? .mock
            startScreen { builder.commentsView(router: $0, delegate: CommentsDelegate(session: session)) }
        } else if processInfoContains("STARTSCREEN_OWN_PROFILE") {
            startScreen { builder.socialProfileView(router: $0, delegate: SocialProfileDelegate(user: UserModel.mocks[0])) }
        } else if processInfoContains("STARTSCREEN_NOTIFICATIONS") {
            startScreen { builder.notificationsView(router: $0) }
        } else if processInfoContains("STARTSCREEN_SHARE_CARD") {
            // The card alone, full screen, for a screenshot. Later mock sessions carry records.
            WorkoutShareCardView(content: .preview, format: .story)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
        } else {
            builder.build()
        }
    }

    /// The flows are covers in the app, so they are presented as covers here too: a flow mounted
    /// as the root could not dismiss itself. The sign-in `AppView` performs at launch has already
    /// happened by the time a cover opens in the app; here nothing else does it.
    private func startScreen<Screen: View>(@ViewBuilder _ screen: @escaping (AnyRouter) -> Screen) -> some View {
        RouterView { router in
            Color.clear
                .task {
                    if let auth = interactor.auth {
                        try? await interactor.logIn(user: auth, isNewUser: false)
                    }
                    router.showScreen(.fullScreenCover) { router in
                        screen(router)
                    }
                }
        }
    }
}
