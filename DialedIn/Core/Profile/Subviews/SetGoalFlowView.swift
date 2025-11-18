//
//  SetGoalFlowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct SetGoalFlowView: View {

    @Environment(\.dismiss) private var dismiss

    @State var path: [OnboardingPathOption] = []

    @ViewBuilder var onboardingOverarchingObjectiveView: (OnboardingOverarchingObjectiveViewDelegate) -> AnyView

    var body: some View {
        NavigationStack {
            onboardingOverarchingObjectiveView(
                OnboardingOverarchingObjectiveViewDelegate(
                    path: $path
                )
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .environment(\.goalFlowDismissAction, { dismiss() })
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.setGoalFlowView()
        .previewEnvironment()
}
