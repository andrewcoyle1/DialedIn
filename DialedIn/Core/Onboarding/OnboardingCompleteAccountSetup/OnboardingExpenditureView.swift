//
//  OnboardingExpenditureView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingExpenditureView: View {
    @Environment(DependencyContainer.self) private var container

    @Environment(UserManager.self) private var userManager
    @Environment(NutritionManager.self) private var nutritionManager
    @Environment(LogManager.self) private var logManager

    let gender: Gender
    let dateOfBirth: Date
    let height: Double
    let weight: Double
    let exerciseFrequency: ExerciseFrequency
    let activityLevel: ActivityLevel
    let lengthUnitPreference: LengthUnitPreference
    let weightUnitPreference: WeightUnitPreference
    let selectedCardioFitness: CardioFitnessLevel
    
    // Computed from collected data
    @State private var totalExpenditureKcal: Int = 0
    private var breakdownItems: [Breakdown] {
        // Breakdown aligned with the actual formula used for TDEE
        // TDEE = BMR * (baseActivityMultiplier + exerciseAdjustment)
        let bmrCals = bmrInt
        let activityCals = max(Int((bmr * max(baseActivityMultiplier - 1.0, 0)).rounded()), 0)
        let exerciseCals = max(Int((bmr * max(exerciseAdjustment, 0)).rounded()), 0)
        // Use remainder as TEF to ensure components sum to displayed TDEE (accounts for rounding)
        let tefCals = max(totalExpenditureKcal - bmrCals - activityCals - exerciseCals, 0)
        return [
            Breakdown(name: "Basal Metabolic Rate", calories: bmrCals, color: .blue),
            Breakdown(name: "Daily Activity", calories: activityCals, color: .green),
            Breakdown(name: "Exercise", calories: exerciseCals, color: .orange),
            Breakdown(name: "Thermic Effect of Food", calories: tefCals, color: .pink)
        ]
    }

    @State private var displayedKcal: Int = 0
    @State private var animateBreakdown: Bool = false
    @State private var hasAnimated: Bool = false

    @State private var isLoading: Bool = true
    
    @State private var showAlert: AnyAppAlert?
    @State private var isSaving: Bool = false
    @State private var currentSaveTask: Task<Void, Never>?
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
        
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
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $isLoading, content: {
            ProgressView()
                .tint(.white)
        })
        .task {
            calculateExpenditure()
        }
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(container: container))
        }
        #endif
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            NavigationLink {
                OnboardingHealthDisclaimerView()
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
                    Text("\(displayedKcal)")
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
                    ProgressView(value: animateBreakdown ? progress(for: item) : 0)
                        .tint(item.color)
                        .animation(.easeOut(duration: 1.0), value: animateBreakdown)
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
                    Text("\(bmrInt) kcal")
                        .foregroundStyle(.secondary)
                }
                Divider()
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Activity Level Multiplier")
                        Text(activityDescription)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: "× %.2f", baseActivityMultiplier))
                        .foregroundStyle(.secondary)
                }
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Exercise Frequency Adjustment")
                        Text(exerciseDescription)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: "+ %.2f", exerciseAdjustment))
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
                    Text("\(tdeeInt) kcal/day")
                        .fontWeight(.semibold)
                }
            }
        } header: {
            Text("How we calculated this")
        } footer: {
            Text("BMR uses your age, height, weight and sex. We then scale by daily activity and how often you exercise. Minimum safeguards may apply elsewhere when setting calorie targets.")
        }
    }

    // MARK: - Calculation details (mirrors NutritionManager.estimateTDEE)
    private var ageYears: Int {
        let years = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 30
        return max(14, years)
    }
    private var weightKg: Double { max(weight, 30) }
    private var heightCm: Double { max(height, 120) }
    private var mifflinGenderCoefficient: Double { (gender == .male) ? 5 : -161 }
    private var bmr: Double { (10 * weightKg) + (6.25 * heightCm) - (5 * Double(ageYears)) + mifflinGenderCoefficient }
    private var bmrInt: Int { Int(bmr.rounded()) }

    private var baseActivityMultiplier: Double {
        switch activityLevel {
        case .sedentary: return 1.2
        case .light: return 1.35
        case .moderate: return 1.5
        case .active: return 1.7
        case .veryActive: return 1.9
        }
    }
    private var activityDescription: String {
        switch activityLevel {
        case .sedentary: return "Mostly sitting; little movement"
        case .light: return "Light movement most of the day"
        case .moderate: return "On feet or moving regularly"
        case .active: return "Physically active work or lifestyle"
        case .veryActive: return "Highly active throughout the day"
        }
    }
    private var exerciseAdjustment: Double {
        switch exerciseFrequency {
        case .never: return 0.0
        case .oneToTwo: return 0.05
        case .threeToFour: return 0.10
        case .fiveToSix: return 0.15
        case .daily: return 0.20
        }
    }
    private var exerciseDescription: String {
        switch exerciseFrequency {
        case .never: return "No structured exercise"
        case .oneToTwo: return "1–2 sessions per week"
        case .threeToFour: return "3–4 sessions per week"
        case .fiveToSix: return "5–6 sessions per week"
        case .daily: return "Exercise most days"
        }
    }
    private var tdeeFromInputs: Double { max(1000, bmr * (baseActivityMultiplier + exerciseAdjustment)) }
    private var tdeeInt: Int { Int(tdeeFromInputs.rounded()) }
    
    private struct Breakdown: Identifiable {
        let id = UUID()
        let name: String
        let calories: Int
        let color: Color
    }

    private func progress(for item: Breakdown) -> Double {
        guard totalExpenditureKcal > 0 else { return 0 }
        return Double(item.calories) / Double(totalExpenditureKcal)
    }
    
    private func calculateExpenditure() {
        // Cancel any existing save to prevent race conditions
        currentSaveTask?.cancel()

        currentSaveTask = Task { @MainActor in
            isSaving = true
            defer {
                isSaving = false
                currentSaveTask = nil
            }

            logManager.trackEvent(event: Event.profileSaveStart)
            do {
                let updated = try await performOperationWithTimeout {
                    try await userManager.saveCompleteAccountSetupProfile(
                        dateOfBirth: dateOfBirth,
                        gender: gender,
                        heightCentimeters: height,
                        weightKilograms: weight,
                        exerciseFrequency: mapExerciseFrequency(exerciseFrequency),
                        dailyActivityLevel: mapDailyActivityLevel(activityLevel),
                        cardioFitnessLevel: mapCardioFitnessLevel(selectedCardioFitness),
                        lengthUnitPreference: lengthUnitPreference,
                        weightUnitPreference: weightUnitPreference
                    )
                }

                // Compute TDEE using the updated user profile
                let tdee = nutritionManager.estimateTDEE(user: updated)
                totalExpenditureKcal = Int(tdee.rounded())
                guard !hasAnimated else { return }
                hasAnimated = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 1.6)) {
                        displayedKcal = totalExpenditureKcal
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        animateBreakdown = true
                    }
                }
                logManager.trackEvent(event: Event.profileSaveSuccess)
                isLoading = false
            } catch {
                logManager.trackEvent(event: Event.profileSaveFail(error: error))
                handleSaveError(error)
            }
        }
    }
    
    // MARK: - Error Handling Helpers
    
    private func handleSaveError(_ error: Error) {
        let errorInfo = AuthErrorHandler.handle(error, operation: "save profile", logManager: logManager)
        showAlert = AnyAppAlert(
            title: errorInfo.title,
            subtitle: errorInfo.message,
            buttons: {
                AnyView(
                    HStack {
                        Button("Cancel") { }
                        if errorInfo.isRetryable {
                            Button("Try Again") { calculateExpenditure() }
                        }
                    }
                )
            }
        )
    }

    // MARK: - Timeout Helper
    
    @discardableResult
    private func performOperationWithTimeout<T: Sendable>(_ operation: @escaping @Sendable () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            group.addTask {
                try await Task.sleep(for: .seconds(AuthConstants.authTimeout))
                throw AuthTimeoutError.operationTimeout
            }
            guard let result = try await group.next() else {
                throw AuthTimeoutError.operationTimeout
            }
            group.cancelAll()
            return result
        }
    }
}

#Preview("Functioning") {
    NavigationStack {
        OnboardingExpenditureView(gender: .male, dateOfBirth: Date(), height: 175, weight: 80, exerciseFrequency: .fiveToSix, activityLevel: .active, lengthUnitPreference: .centimeters, weightUnitPreference: .kilograms, selectedCardioFitness: .intermediate)
    }
    .previewEnvironment()
}

#Preview("Slow Loading") {
    NavigationStack {
        OnboardingExpenditureView(gender: .male, dateOfBirth: Date(), height: 175, weight: 80, exerciseFrequency: .fiveToSix, activityLevel: .active, lengthUnitPreference: .centimeters, weightUnitPreference: .kilograms, selectedCardioFitness: .intermediate)
    }
    .environment(UserManager(services: MockUserServices(user: .mock, delay: 3)))
    .previewEnvironment()
}

#Preview("Failed") {
    NavigationStack {
        OnboardingExpenditureView(gender: .male, dateOfBirth: Date(), height: 175, weight: 80, exerciseFrequency: .fiveToSix, activityLevel: .active, lengthUnitPreference: .centimeters, weightUnitPreference: .kilograms, selectedCardioFitness: .intermediate)
    }
    .environment(UserManager(services: MockUserServices(user: .mock, showError: true)))
    .previewEnvironment()
}

// MARK: - Events

private extension OnboardingExpenditureView {
    enum Event: LoggableEvent {
        case profileSaveStart
        case profileSaveSuccess
        case profileSaveFail(error: Error)
        
        var eventName: String {
            switch self {
            case .profileSaveStart: return "OnboardingCardio_SaveProfile_Start"
            case .profileSaveSuccess: return "OnboardingCardio_SaveProfile_Success"
            case .profileSaveFail: return "OnboardingCardio_SaveProfile_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .profileSaveFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .profileSaveFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

// MARK: - Mapping helpers
private func mapExerciseFrequency(_ value: ExerciseFrequency) -> ProfileExerciseFrequency {
    switch value {
    case .never: return .never
    case .oneToTwo: return .oneToTwo
    case .threeToFour: return .threeToFour
    case .fiveToSix: return .fiveToSix
    case .daily: return .daily
    }
}

private func mapDailyActivityLevel(_ value: ActivityLevel) -> ProfileDailyActivityLevel {
    switch value {
    case .sedentary: return .sedentary
    case .light: return .light
    case .moderate: return .moderate
    case .active: return .active
    case .veryActive: return .veryActive
    }
}

private func mapCardioFitnessLevel(_ value: CardioFitnessLevel) -> ProfileCardioFitnessLevel {
    switch value {
    case .beginner: return .beginner
    case .novice: return .novice
    case .intermediate: return .intermediate
    case .advanced: return .advanced
    case .elite: return .elite
    }
}
