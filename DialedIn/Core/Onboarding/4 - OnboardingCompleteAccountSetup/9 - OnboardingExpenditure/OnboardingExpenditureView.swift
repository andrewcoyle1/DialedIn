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
    var userBuilder: UserModelBuilder

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
        .onFirstTask {
            await viewModel.checkCanRequestPermissions()
        }
        .task {
            viewModel.estimateExpenditure(userModelBuilder: userBuilder)
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
                viewModel.saveAndNavigate(path: $path, userModelBuilder: userBuilder)
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
    
    private var breakdownItems: [OnboardingExpenditureViewModel.Breakdown] {
        guard let weight = userBuilder.weight,
              let height = userBuilder.height,
              let dateOfBirth = userBuilder.dateOfBirth,
              let activityLevel = userBuilder.activityLevel,
              let exerciseFrequency = userBuilder.exerciseFrequency else {
            return []
        }
        let context = OnboardingExpenditureViewModel.ExpenditureContext(
            weight: weight,
            height: height,
            dateOfBirth: dateOfBirth,
            gender: userBuilder.gender,
            activityLevel: activityLevel,
            exerciseFrequency: exerciseFrequency
        )
        return viewModel.breakdownItems(context: context)
    }
    
    private var breakdownSection: some View {
        Section("Breakdown") {
            ForEach(breakdownItems) { item in
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
                    Text("\(calculatedBmrInt) kcal")
                        .foregroundStyle(.secondary)
                }
                Divider()
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Activity Level Multiplier")
                        Text(activityDescriptionText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: "× %.2f", calculatedBaseActivityMultiplier))
                        .foregroundStyle(.secondary)
                }
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Exercise Frequency Adjustment")
                        Text(exerciseDescriptionText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: "+ %.2f", calculatedExerciseAdjustment))
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
                    Text("\(calculatedTdeeInt) kcal/day")
                        .fontWeight(.semibold)
                }
            }
        } header: {
            Text("How we calculated this")
        } footer: {
            Text("BMR uses your age, height, weight and sex. We then scale by daily activity and how often you exercise. Minimum safeguards may apply elsewhere when setting calorie targets.")
        }
    }
    
    private var calculatedBmrInt: Int {
        guard let weight = userBuilder.weight,
              let height = userBuilder.height,
              let dateOfBirth = userBuilder.dateOfBirth else {
            return 0
        }
        return viewModel.bmrInt(
            weight: weight,
            height: height,
            dateOfBirth: dateOfBirth,
            gender: userBuilder.gender
        )
    }
    
    private var activityDescriptionText: String {
        guard let activityLevel = userBuilder.activityLevel else {
            return "N/A"
        }
        return viewModel.activityDescription(activityLevel: activityLevel)
    }
    
    private var calculatedBaseActivityMultiplier: Double {
        guard let activityLevel = userBuilder.activityLevel else {
            return 1.0
        }
        return viewModel.baseActivityMultiplier(activityLevel: activityLevel)
    }
    
    private var exerciseDescriptionText: String {
        guard let exerciseFrequency = userBuilder.exerciseFrequency else {
            return "N/A"
        }
        return viewModel.exerciseDescription(exerciseFrequency: exerciseFrequency)
    }
    
    private var calculatedExerciseAdjustment: Double {
        guard let exerciseFrequency = userBuilder.exerciseFrequency else {
            return 0.0
        }
        return viewModel.exerciseAdjustment(exerciseFrequency: exerciseFrequency)
    }
    
    private var calculatedTdeeInt: Int {
        guard let weight = userBuilder.weight,
              let height = userBuilder.height,
              let dateOfBirth = userBuilder.dateOfBirth,
              let activityLevel = userBuilder.activityLevel,
              let exerciseFrequency = userBuilder.exerciseFrequency else {
            return 0
        }
        let context = OnboardingExpenditureViewModel.ExpenditureContext(
            weight: weight,
            height: height,
            dateOfBirth: dateOfBirth,
            gender: userBuilder.gender,
            activityLevel: activityLevel,
            exerciseFrequency: exerciseFrequency
        )
        return viewModel.tdeeInt(context: context)
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
            path: $path,
            userBuilder: UserModelBuilder.mock
        )
    }
    .previewEnvironment()
}
