//
//  SetGoalFlowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct SetGoalFlowView: View {
    @Environment(CoreBuilder.self) private var builder
    @Environment(\.dismiss) private var dismiss
    @State var path: [OnboardingPathOption] = []
    
    var body: some View {
        NavigationStack {
            builder.onboardingOverarchingObjectiveView(
                delegate: OnboardingOverarchingObjectiveViewDelegate(
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
    SetGoalFlowView()
        .previewEnvironment()
}
