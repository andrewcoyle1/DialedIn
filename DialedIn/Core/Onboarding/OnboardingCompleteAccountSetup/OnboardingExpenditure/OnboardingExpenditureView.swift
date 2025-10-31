//
//  OnboardingExpenditureView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingExpenditureView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingExpenditureViewModel
    @Binding var path: [OnboardingPathOption]

    var body: some View {
        List {
            overviewSection
            breakdownSection
            explanationSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Expenditure")
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: $viewModel.isLoading, content: {
            ProgressView()
                .tint(.white)
        })
        .task {
            viewModel.calculateExpenditure()
        }
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
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
                viewModel.navigateToHealthDisclaimer(path: $path)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    private var overviewSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(viewModel.displayedKcal)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .frame(minWidth: 170)
                    Text("kcal/day")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("An estimate of calories burned per day")
        } footer: {
            Text("This is your estimated total daily energy expenditure.")
        }
    }
    
    private var breakdownSection: some View {
        Section("Breakdown") {
            ForEach(viewModel.breakdownItems) { item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.name)
                            .font(.subheadline)
                        Spacer()
                        Text("\(item.calories) kcal")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: viewModel.animateBreakdown ? viewModel.progress(for: item) : 0)
                        .tint(item.color)
                        .animation(.easeOut(duration: 1.0), value: viewModel.animateBreakdown)
                }
                .padding(.vertical, 6)
            }
        }
    }
    
    // MARK: - Explanation
    private var explanationSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("BMR (Mifflin-St Jeor)")
                    Spacer()
                    Text("\(viewModel.bmrInt) kcal")
                        .foregroundStyle(.secondary)
                }
                Divider()
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Activity Level Multiplier")
                        Text(viewModel.activityDescription)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: "× %.2f", viewModel.baseActivityMultiplier))
                        .foregroundStyle(.secondary)
                }
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Exercise Frequency Adjustment")
                        Text(viewModel.exerciseDescription)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: "+ %.2f", viewModel.exerciseAdjustment))
                        .foregroundStyle(.secondary)
                }
                Divider()
                HStack {
                    Text("TDEE Formula")
                    Spacer()
                    Text("BMR × (activity + exercise)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("TDEE Result")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(viewModel.tdeeInt) kcal/day")
                        .fontWeight(.semibold)
                }
            }
        } header: {
            Text("How we calculated this")
        } footer: {
            Text("BMR uses your age, height, weight and sex. We then scale by daily activity and how often you exercise. Minimum safeguards may apply elsewhere when setting calorie targets.")
        }
    }
}

#Preview("Functioning") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        OnboardingExpenditureView(
            viewModel: OnboardingExpenditureViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ),
            path: $path
        )
    }
    .previewEnvironment()
}
