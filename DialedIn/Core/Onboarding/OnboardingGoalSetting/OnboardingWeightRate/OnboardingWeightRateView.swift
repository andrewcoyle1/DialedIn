//
//  OnboardingWeightRateView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingWeightRateView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingWeightRateViewModel
    
    var body: some View {
        List {
            if viewModel.didInitialize {
                rateSelectionSection
                rateDetailsSection
                additionalInfoSection
            } else {
                loadingSection
            }
        }
        .showModal(showModal: Binding(
            get: { viewModel.isLoading },
            set: { _ in }
        )) {
            ProgressView()
                .tint(.white)
        }
        .navigationTitle("At what rate?")
        .onFirstAppear {
            viewModel.onAppear()
        }
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
        .showCustomAlert(alert: $viewModel.showAlert)
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
            NavigationLink {
                OnboardingGoalSummaryView(
                    viewModel: OnboardingGoalSummaryViewModel(
                        interactor: CoreInteractor(
                            container: container
                        ),
                        objective: viewModel.objective,
                        targetWeight: viewModel.targetWeight,
                        weightRate: viewModel.weightChangeRate,
                        isStandaloneMode: viewModel.isStandaloneMode
                    )
                )
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    private var rateSelectionSection: some View {
        Section {
            VStack(spacing: 16) {
                Text(viewModel.currentRateCategory.title)
                    .font(.headline)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Native SwiftUI Slider
                VStack(spacing: 8) {
                    Slider(
                        value: $viewModel.weightChangeRate,
                        in: viewModel.minWeightChangeRate...viewModel.maxWeightChangeRate,
                        step: 0.05
                    )
                    .tint(.green)
                    .disabled(viewModel.isLoading)
                    
                    // Tick marks and labels
                    HStack {
                        ForEach([viewModel.minWeightChangeRate, (viewModel.minWeightChangeRate + viewModel.maxWeightChangeRate) / 2, viewModel.maxWeightChangeRate], id: \.self) { value in
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.6))
                                    .frame(width: 1, height: 8)
                                Text("\(String(format: "%.1f", value))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            if value < viewModel.maxWeightChangeRate {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .padding()
            }
            .padding(.vertical, 8)
        }
        .removeListRowFormatting()
    }
    
    private var rateDetailsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.weeklyWeightChangeText)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(viewModel.monthlyWeightChangeText)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
        .removeListRowFormatting()
        .padding(.horizontal)
    }
    
    private var additionalInfoSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.estimatedCalorieTargetText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                Text(viewModel.estimatedEndDateText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
        .removeListRowFormatting()
        .padding(.horizontal)

    }
    
    private var loadingSection: some View {
        Section {
            ProgressView()
                .frame(height: 200)
                .frame(maxWidth: .infinity)
        }
        .removeListRowFormatting()
    }
}

#Preview("Gain Weight") {
    NavigationStack {
        OnboardingWeightRateView(
            viewModel: OnboardingWeightRateViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                objective: .gainWeight,
                targetWeight: 80
            )
        )
    }
    .previewEnvironment()
}

#Preview("Lose Weight") {
    NavigationStack {
        OnboardingWeightRateView(
            viewModel: OnboardingWeightRateViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                objective: .loseWeight,
                targetWeight: 60
            )
        )
    }
    .previewEnvironment()
}
