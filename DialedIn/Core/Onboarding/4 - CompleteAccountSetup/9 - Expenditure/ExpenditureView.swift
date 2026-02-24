//
//  ExpenditureView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct ExpenditureDelegate {
    let gender: Gender
    let dateOfBirth: Date
    let heightInCentimetres: Double
    let lengthUnitPreference: LengthUnitPreference
    let weightInKilograms: Double
    let weightUnitPreference: WeightUnitPreference
    let exerciseFrequency: ExerciseFrequency
    let activityLevel: ActivityLevel
    let cardioFitnessLevel: CardioFitnessLevel
    
    init(delegate: CardioFitnessDelegate, cardioFitnessLevel: CardioFitnessLevel) {
        self.gender = delegate.gender
        self.dateOfBirth = delegate.dateOfBirth
        self.heightInCentimetres = delegate.heightInCentimetres
        self.lengthUnitPreference = delegate.lengthUnitPreference
        self.weightInKilograms = delegate.weightInKilograms
        self.weightUnitPreference = delegate.weightUnitPreference
        self.exerciseFrequency = delegate.exerciseFrequency
        self.activityLevel = delegate.activityLevel
        self.cardioFitnessLevel = cardioFitnessLevel
    }
    
    static var mock: Self {
        Self(delegate: .mock, cardioFitnessLevel: .intermediate)
    }

}

struct ExpenditureView: View {

    @State var presenter: ExpenditurePresenter

    var delegate: ExpenditureDelegate

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
            presenter.estimateExpenditure(delegate: delegate)
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
            .disabled(!presenter.canContinue)
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
    
    private var breakdownItems: [ExpenditurePresenter.Breakdown] {
        
        let context = ExpenditurePresenter.ExpenditureContext(
            weight: delegate.weightInKilograms,
            height: delegate.heightInCentimetres,
            dateOfBirth: delegate.dateOfBirth,
            gender: delegate.gender,
            activityLevel: delegate.activityLevel,
            exerciseFrequency: delegate.exerciseFrequency
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

        return presenter.bmrInt(
            weight: delegate.weightInKilograms,
            height: delegate.heightInCentimetres,
            dateOfBirth: delegate.dateOfBirth,
            gender: delegate.gender
        )
    }
    
    private var activityDescriptionText: String {
        
        return presenter.activityDescription(activityLevel: delegate.activityLevel)
    }
    
    private var calculatedBaseActivityMultiplier: Double {
        return presenter.baseActivityMultiplier(activityLevel: delegate.activityLevel)
    }
    
    private var exerciseDescriptionText: String {
        return presenter.exerciseDescription(exerciseFrequency: delegate.exerciseFrequency)
    }
    
    private var calculatedExerciseAdjustment: Double {
        return presenter.exerciseAdjustment(exerciseFrequency: delegate.exerciseFrequency)
    }
    
    private var calculatedTdeeInt: Int {

        let context = ExpenditurePresenter.ExpenditureContext(
            weight: delegate.weightInKilograms,
            height: delegate.heightInCentimetres,
            dateOfBirth: delegate.dateOfBirth,
            gender: delegate.gender,
            activityLevel: delegate.activityLevel,
            exerciseFrequency: delegate.exerciseFrequency
        )
        return presenter.tdeeInt(context: context)
    }
}

extension CoreBuilder {
    func expenditureView(router: AnyRouter, delegate: ExpenditureDelegate) -> some View {
        ExpenditureView(
            presenter: ExpenditurePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showExpenditureView(delegate: ExpenditureDelegate) {
        router.showScreen(.push) { router in
            builder.expenditureView(router: router, delegate: delegate)
        }
    }

}

#Preview("Functioning") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.expenditureView(
            router: router, 
            delegate: .mock
        )
    }
    
}
