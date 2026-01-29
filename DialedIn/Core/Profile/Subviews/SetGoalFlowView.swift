//
//  SetGoalFlowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct SetGoalFlowView: View {

    @Environment(\.dismiss) private var dismiss

    @ViewBuilder var onboardingOverarchingObjectiveView: () -> AnyView

    var body: some View {
        onboardingOverarchingObjectiveView()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        .environment(\.goalFlowDismissAction, { dismiss() })
    }
}

// #Preview {
//     let builder = CoreBuilder(container: DevPreview.shared.container())
//     RouterView { router in
//         builder.setGoalFlowView(router: router)
//     }
//     .previewEnvironment()
// }
