//
//  CoreRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/11/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
struct CoreRouter: GlobalRouter {

    let router: AnyRouter
    let builder: CoreBuilder
    
    func showWorkoutStartModal(delegate: WorkoutStartDelegate) {
        router.showModal(transition: AnyTransition.opacity, backgroundColor: Color.black.opacity(0.6)) {
            builder.workoutStartModal(delegate: delegate)
        }
    }
    
    func showWarmupSetInfoModal(primaryButtonAction: @escaping () -> Void) {
        router.showModal(
            transition: .move(edge: .bottom),
            backgroundColor: .black.opacity(0.3),
            destination: {
                CustomModalView(
                    title: "Warmup Sets",
                    subtitle: "Warmup sets are lighter weight sets performed before your working sets to prepare your muscles and joints. They don't count toward your total volume or personal records.",
                    primaryButtonTitle: "Got it",
                    primaryButtonAction: {
                        primaryButtonAction()
                    },
                    secondaryButtonTitle: "",
                    secondaryButtonAction: {}
                )
            }
        )
    }


}
