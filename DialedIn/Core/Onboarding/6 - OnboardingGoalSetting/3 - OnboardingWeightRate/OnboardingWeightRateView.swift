//
//  OnboardingWeightRateView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingWeightRateView: View {

    @State var presenter: OnboardingWeightRatePresenter

    var delegate: OnboardingWeightRateDelegate

    var body: some View {
        List {
            if presenter.didInitialize {
                rateSelectionSection
                rateDetailsSection
                additionalInfoSection
            } else {
                loadingSection
            }
        }
        .showModal(showModal: Binding(
            get: { presenter.isLoading },
            set: { _ in }
        )) {
            ProgressView()
                .tint(.white)
        }
        .navigationTitle("At what rate?")
        .onFirstAppear {
            presenter.onAppear(weightGoalBuilder: delegate.weightGoalBuilder)
        }
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.navigateToGoalSummary(weightGoalBuilder: delegate.weightGoalBuilder
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
                Text(presenter.currentRateCategory.title)
                    .font(.headline)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Native SwiftUI Slider
                VStack(spacing: 8) {
                    Slider(
                        value: $presenter.weightChangeRate,
                        in: presenter.minWeightChangeRate...presenter.maxWeightChangeRate,
                        step: 0.05
                    )
                    .tint(.green)
                    .disabled(presenter.isLoading)
                    
                    // Tick marks and labels
                    HStack {
                        ForEach([presenter.minWeightChangeRate, (presenter.minWeightChangeRate + presenter.maxWeightChangeRate) / 2, presenter.maxWeightChangeRate], id: \.self) { value in
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.6))
                                    .frame(width: 1, height: 8)
                                Text("\(String(format: "%.1f", value))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            if value < presenter.maxWeightChangeRate {
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
                Text(presenter.weeklyWeightChangeText(weightGoalBuilder: delegate.weightGoalBuilder))
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(presenter.monthlyWeightChangeText(weightGoalBuilder: delegate.weightGoalBuilder))
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
                Text(presenter.estimatedCalorieTargetText(weightGoalBuilder: delegate.weightGoalBuilder))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                Text(presenter.estimatedEndDateText(weightGoalBuilder: delegate.weightGoalBuilder))
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
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingWeightRateView(
            router: router,
            delegate: OnboardingWeightRateDelegate(weightGoalBuilder: .weightRateMock)
        )
    }
    .previewEnvironment()
}

#Preview("Lose Weight") {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingWeightRateView(
            router: router,
            delegate: OnboardingWeightRateDelegate(weightGoalBuilder: .weightRateMock)
        )
    }
    .previewEnvironment()
}
