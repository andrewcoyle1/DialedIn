//
//  WeightRateView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct WeightRateDelegate {
    let overarchingObjective: OverarchingObjective
    let targetWeight: Double
    
    init(delegate: TargetWeightDelegate, targetWeight: Double) {
        self.overarchingObjective = delegate.overarchingObjective
        self.targetWeight = targetWeight
    }
    
    static func mock(overarchingObjective: OverarchingObjective) -> Self {
        Self(delegate: .mock(overarchingObjective: overarchingObjective), targetWeight: 60)
    }
}

struct WeightRateView: View {

    @State var presenter: WeightRatePresenter

    var delegate: WeightRateDelegate

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
        .navigationTitle("At what rate?")
        .onFirstAppear {
            presenter.onAppear(delegate: delegate)
        }
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.onContinuePressed(delegate: delegate)
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding(.horizontal)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
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
                Text(presenter.weeklyWeightChangeText(delegate: delegate))
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(presenter.monthlyWeightChangeText(delegate: delegate))
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
                Text(presenter.estimatedCalorieTargetText(delegate: delegate))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                Text(presenter.estimatedEndDateText(delegate: delegate))
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

extension CoreBuilder {
    func weightRateView(router: AnyRouter, delegate: WeightRateDelegate) -> some View {
        WeightRateView(
            presenter: WeightRatePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showWeightRateView(delegate: WeightRateDelegate) {
        router.showScreen(.push) { router in
            builder.weightRateView(router: router, delegate: delegate)
        }
    }
}

#Preview("Gain Weight") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.weightRateView(
            router: router,
            delegate: .mock(overarchingObjective: .gainWeight)
        )
    }
    
}

#Preview("Lose Weight") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.weightRateView(
            router: router,
            delegate: .mock(overarchingObjective: .loseWeight)
        )
    }
    
}
