//
//  CoreInteractor+Expenditure.swift
//  DialedIn
//

import Foundation

extension CoreInteractor {

    // MARK: - ExpenditureEngine

    /// One estimate per day from the user's first logged day through today.
    ///
    /// The engine is pure, so everything it needs is gathered here: the three logs, the settings,
    /// the existing formula TDEE as the prior, and today. Recomputed on every read — it is a few
    /// thousand arithmetic operations over a year of data, and the alternative is a stored estimate
    /// that has to be migrated forever.
    var expenditureHistory: [ExpenditureEstimate] {
        ExpenditureEngine().history(
            samples: expenditureSamples,
            priorKcal: estimateTDEE(user: currentUser),
            settings: nutritionStrategySettings,
            today: Date(),
            calendar: .current
        )
    }

    /// Today's estimate — the figure the settings screen shows and the proposal is built on.
    var currentExpenditure: ExpenditureEstimate {
        ExpenditureEngine().current(
            samples: expenditureSamples,
            priorKcal: estimateTDEE(user: currentUser),
            settings: nutritionStrategySettings,
            today: Date(),
            calendar: .current
        )
    }

    private var expenditureSamples: [DailySample] {
        ExpenditureSampleBuilder.samples(
            mealLogs: userMeals,
            measurements: bodyMeasurements,
            steps: stepsHistory,
            today: Date()
        )
    }

    // MARK: - TargetProposal

    /// The pending suggestion that the calorie target should move, or nil when there is nothing
    /// worth saying.
    var targetProposal: TargetProposal? {
        TargetProposal.make(
            estimate: currentExpenditure,
            plan: currentDietPlan,
            goal: currentGoal,
            settings: nutritionStrategySettings,
            dismissedKcal: dismissedTargetProposalKcal
        )
    }

    /// Recomputes the plan at the proposed target and saves it.
    ///
    /// `computeDietPlan` takes one number and spreads it across the week, so the figure handed to
    /// it is the proposed target — expenditure with the goal's rate already in it — not the bare
    /// expenditure. Passing the expenditure would quietly put everyone on maintenance.
    func acceptTargetProposal() async throws {
        guard let proposal = targetProposal, let plan = currentDietPlan else { return }
        let updated = nutritionManager.computeDietPlan(
            user: currentUser,
            delegate: DietPlanDelegate(plan: plan),
            trainingProgram: activeTrainingProgram,
            expenditureKcal: proposal.proposedTargetKcal
        )
        try await saveDietPlan(updated)
        clearDismissedTargetProposal()
    }

    /// Remembers the figure waved away, so the same card does not come back tomorrow.
    func dismissTargetProposal() {
        guard let proposal = targetProposal else { return }
        UserDefaults.standard.set(proposal.proposedTargetKcal, forKey: TargetProposal.dismissedDefaultsKey)
    }

    private var dismissedTargetProposalKcal: Double? {
        guard UserDefaults.standard.object(forKey: TargetProposal.dismissedDefaultsKey) != nil else { return nil }
        return UserDefaults.standard.double(forKey: TargetProposal.dismissedDefaultsKey)
    }

    private func clearDismissedTargetProposal() {
        UserDefaults.standard.removeObject(forKey: TargetProposal.dismissedDefaultsKey)
    }
}

extension DietPlanDelegate {

    /// The selections a saved plan was built from, so recomputing it changes only the calories.
    ///
    /// `DietPlan` stores them as raw strings; anything unreadable falls back to the same default
    /// the onboarding picker starts on rather than silently changing the user's diet shape.
    init(plan: DietPlan) {
        self.init(
            preferredDiet: PreferredDiet(rawValue: plan.preferredDiet) ?? .balanced,
            calorieFloor: CalorieFloor(rawValue: plan.calorieFloor) ?? .standard,
            calorieDistribution: CalorieDistribution(rawValue: plan.calorieDistribution) ?? .even,
            proteinIntake: ProteinIntake(rawValue: plan.proteinIntake) ?? .moderate,
            isFromSettings: true
        )
    }
}
