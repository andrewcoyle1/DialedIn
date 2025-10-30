//
//  OnboardingActivityView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingActivityView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingActivityViewModel
    @Binding var path: [OnboardingPathOption]

    enum NavigationDestination {
        case cardioFitness(gender: Gender, dateOfBirth: Date, height: Double, weight: Double, exerciseFrequency: ExerciseFrequency, activityLevel: ActivityLevel, lengthUnitPreference: LengthUnitPreference, weightUnitPreference: WeightUnitPreference)
    }
    
    var body: some View {
        List {
            dailyActivitySection
        }
        .navigationTitle("Activity Level")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
    }
    
    private var dailyActivitySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                Text("What's your daily activity level outside of exercise?")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    activityRow(level)
                }
            }
            .removeListRowFormatting()
            .padding(.horizontal)
        } header: {
            Text("Daily Activity")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.navigateToCardioFitness(path: $path)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!viewModel.canSubmit)
        }
    }
    
    private func activityRow(_ level: ActivityLevel) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(level.description)
                    .font(.headline)
                Text(level.detailDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: viewModel.selectedActivityLevel == level ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(viewModel.selectedActivityLevel == level ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            viewModel.selectedActivityLevel = level
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        OnboardingActivityView(
            viewModel: OnboardingActivityViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                gender: .male,
                dateOfBirth: Date(),
                height: 175,                
                weight: 70,
                exerciseFrequency: .threeToFour,
                lengthUnitPreference: .centimeters,
                weightUnitPreference: .kilograms
            ), path: $path
        )
    }
    .previewEnvironment()
}
