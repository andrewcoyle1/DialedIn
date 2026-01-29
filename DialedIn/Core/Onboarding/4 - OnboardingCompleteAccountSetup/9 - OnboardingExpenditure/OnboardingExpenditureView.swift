//
//  OnboardingExpenditureView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingExpenditureView: View {

    @State var presenter: OnboardingExpenditurePresenter

    var delegate: OnboardingExpenditureDelegate

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
        .onFirstTask {
            await presenter.checkCanRequestPermissions()
        }
        .onFirstAppear {
            presenter.estimateExpenditure(userModelBuilder: delegate.userBuilder)
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
                presenter.saveAndNavigate(userModelBuilder: delegate.userBuilder)
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
                    Text("\(presenter.displayedKcal)")
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
    
    private var breakdownItems: [OnboardingExpenditurePresenter.Breakdown] {
        let userBuilder = delegate.userBuilder
        guard let weight = userBuilder.weight,
              let height = userBuilder.height,
              let dateOfBirth = userBuilder.dateOfBirth,
              let activityLevel = userBuilder.activityLevel,
              let exerciseFrequency = userBuilder.exerciseFrequency else {
            return []
        }
        let context = OnboardingExpenditurePresenter.ExpenditureContext(
            weight: weight,
            height: height,
            dateOfBirth: dateOfBirth,
            gender: userBuilder.gender,
            activityLevel: activityLevel,
            exerciseFrequency: exerciseFrequency
        )
        return presenter.breakdownItems(context: context)
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
                    ProgressView(value: presenter.animateBreakdown ? presenter.progress(for: item) : 0)
                        .tint(item.color)
                        .animation(.easeOut(duration: 1.0), value: presenter.animateBreakdown)
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
        let userBuilder = delegate.userBuilder

        guard let weight = userBuilder.weight,
              let height = userBuilder.height,
              let dateOfBirth = userBuilder.dateOfBirth else {
            return 0
        }
        return presenter.bmrInt(
            weight: weight,
            height: height,
            dateOfBirth: dateOfBirth,
            gender: userBuilder.gender
        )
    }
    
    private var activityDescriptionText: String {
        
        guard let activityLevel = delegate.userBuilder.activityLevel else {
            return "N/A"
        }
        return presenter.activityDescription(activityLevel: activityLevel)
    }
    
    private var calculatedBaseActivityMultiplier: Double {
        guard let activityLevel = delegate.userBuilder.activityLevel else {
            return 1.0
        }
        return presenter.baseActivityMultiplier(activityLevel: activityLevel)
    }
    
    private var exerciseDescriptionText: String {
        guard let exerciseFrequency = delegate.userBuilder.exerciseFrequency else {
            return "N/A"
        }
        return presenter.exerciseDescription(exerciseFrequency: exerciseFrequency)
    }
    
    private var calculatedExerciseAdjustment: Double {
        guard let exerciseFrequency = delegate.userBuilder.exerciseFrequency else {
            return 0.0
        }
        return presenter.exerciseAdjustment(exerciseFrequency: exerciseFrequency)
    }
    
    private var calculatedTdeeInt: Int {
        let userBuilder = delegate.userBuilder
        guard let weight = userBuilder.weight,
              let height = userBuilder.height,
              let dateOfBirth = userBuilder.dateOfBirth,
              let activityLevel = userBuilder.activityLevel,
              let exerciseFrequency = userBuilder.exerciseFrequency else {
            return 0
        }
        let context = OnboardingExpenditurePresenter.ExpenditureContext(
            weight: weight,
            height: height,
            dateOfBirth: dateOfBirth,
            gender: userBuilder.gender,
            activityLevel: activityLevel,
            exerciseFrequency: exerciseFrequency
        )
        return presenter.tdeeInt(context: context)
    }
}

extension OnbBuilder {
    func onboardingExpenditureView(router: AnyRouter, delegate: OnboardingExpenditureDelegate) -> some View {
        OnboardingExpenditureView(
            presenter: OnboardingExpenditurePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension OnbRouter {
    func showOnboardingExpenditureView(delegate: OnboardingExpenditureDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingExpenditureView(router: router, delegate: delegate)
        }
    }

}

#Preview("Functioning") {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingExpenditureView(
            router: router, 
            delegate: OnboardingExpenditureDelegate(userBuilder: .mock)
        )
    }
    .previewEnvironment()
}
