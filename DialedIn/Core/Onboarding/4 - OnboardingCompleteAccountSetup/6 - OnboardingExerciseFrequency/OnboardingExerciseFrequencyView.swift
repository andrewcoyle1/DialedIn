//
//  OnboardingExerciseFrequencyView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingExerciseFrequencyViewDelegate {
    var userModelBuilder: UserModelBuilder
}

struct OnboardingExerciseFrequencyView: View {

    @State var viewModel: OnboardingExerciseFrequencyViewModel

    var delegate: OnboardingExerciseFrequencyViewDelegate

    var body: some View {
        List {
            exerciseFrequencySection
        }
        .navigationTitle("Exercise Frequency")
        .toolbar {
            toolbarContent
        }
    }
    
    private var exerciseFrequencySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(ExerciseFrequency.allCases, id: \.self) { frequency in
                    frequencyRow(frequency)
                }
            }
            .removeListRowFormatting()
            .padding(.horizontal)
        } header: {
            Text("How often do you exercise?")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.navigateToOnboardingActivity(userBuilder: delegate.userModelBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!viewModel.canSubmit)
        }
    }
    
    private func frequencyRow(_ frequency: ExerciseFrequency) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(frequency.description)
                    .font(.headline)
            }
            Spacer(minLength: 8)
            Image(systemName: viewModel.selectedFrequency == frequency ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(viewModel.selectedFrequency == frequency ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            viewModel.selectedFrequency = frequency
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingExerciseFrequencyView(
            router: router,
            delegate: OnboardingExerciseFrequencyViewDelegate(userModelBuilder: UserModelBuilder.exerciseFrequencyMock)
        )
    }
    .previewEnvironment()
}
