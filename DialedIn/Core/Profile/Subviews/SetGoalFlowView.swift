//
//  SetGoalFlowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct SetGoalFlowView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            OnboardingOverarchingObjectiveView(
                viewModel: OnboardingOverarchingObjectiveViewModel(
                    interactor: CoreInteractor(
                        container: container
                    ),
                    isStandaloneMode: true
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
