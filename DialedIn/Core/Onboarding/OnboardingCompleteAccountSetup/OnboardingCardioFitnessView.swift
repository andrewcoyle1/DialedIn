//
//  OnboardingCardioFitnessView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingCardioFitnessView: View {
    
    @Environment(LogManager.self) private var logManager
    @Environment(UserManager.self) private var userManager
    
    let gender: Gender
    let dateOfBirth: Date
    let height: Double
    let weight: Double
    let exerciseFrequency: ExerciseFrequency
    let activityLevel: ActivityLevel
    let lengthUnitPreference: LengthUnitPreference
    let weightUnitPreference: WeightUnitPreference
    
    @State private var selectedCardioFitness: CardioFitnessLevel?
    @State private var navigationDestination: NavigationDestination?
    @State private var showAlert: AnyAppAlert?
    @State private var isSaving: Bool = false
    @State private var currentSaveTask: Task<Void, Never>?
    
    enum NavigationDestination {
        case expenditure
    }
    
    enum CardioFitnessLevel: String, CaseIterable {
        case beginner
        case novice
        case intermediate
        case advanced
        case elite
        
        var description: String {
            switch self {
            case .beginner:
                return "Beginner"
            case .novice:
                return "Novice"
            case .intermediate:
                return "Intermediate"
            case .advanced:
                return "Advanced"
            case .elite:
                return "Elite"
            }
        }
        
        var detailDescription: String {
            switch self {
            case .beginner:
                return "Just starting cardio, gets winded easily, low endurance"
            case .novice:
                return "Some cardio experience, can handle light jogging, moderate endurance"
            case .intermediate:
                return "Regular cardio, comfortable running, good endurance"
            case .advanced:
                return "Experienced runner, high endurance, can maintain pace"
            case .elite:
                return "Athlete level, exceptional endurance, competitive fitness"
            }
        }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("How would you rate your cardiovascular fitness?")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                    
                    Text("Consider your ability to maintain sustained cardio activities like running, cycling, or swimming.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                    
                    ForEach(CardioFitnessLevel.allCases, id: \.self) { level in
                        cardioFitnessRow(level)
                    }
                }
                .removeListRowFormatting()
                .padding(.horizontal)
            } header: {
                Text("Cardiovascular Fitness")
            }
        }
        .navigationTitle("Cardio Fitness")
        .safeAreaInset(edge: .bottom) {
            Capsule()
                .frame(height: AuthConstants.buttonHeight)
                .frame(maxWidth: .infinity)
                .foregroundStyle((canSubmit && !isSaving) ? Color.accent : Color.gray.opacity(0.3))
                .padding(.horizontal)
                .overlay(alignment: .center) {
                    if !isSaving {
                        Text("Continue")
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 32)
                    } else {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .allowsHitTesting(canSubmit && !isSaving)
                .anyButton(.press) {
                    onContinue()
                }
        }
        .navigationDestination(isPresented: Binding(
            get: { navigationDestination == .expenditure },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            OnboardingExpenditureView()
        }
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $isSaving) {
            ProgressView()
                .tint(.white)
        }
        .onDisappear {
            // Clean up any ongoing tasks and reset loading states
            currentSaveTask?.cancel()
            currentSaveTask = nil
            isSaving = false
        }
    }
    
    private var canSubmit: Bool {
        selectedCardioFitness != nil
    }
    
    private func cardioFitnessRow(_ level: CardioFitnessLevel) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(level.description)
                    .font(.headline)
                Text(level.detailDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: selectedCardioFitness == level ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(selectedCardioFitness == level ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            selectedCardioFitness = level
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func onContinue() {
        guard let selectedCardioFitness = selectedCardioFitness else { return }
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
                guard let existing = userManager.currentUser else {
                    throw NSError(domain: "Onboarding", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing current user"])
                }

                let model = UserModel(
                    userId: existing.userId,
                    email: existing.email,
                    isAnonymous: existing.isAnonymous,
                    firstName: existing.firstName,
                    lastName: existing.lastName,
                    dateOfBirth: dateOfBirth,
                    gender: gender,
                    heightCentimeters: height,
                    weightKilograms: weight,
                    exerciseFrequency: mapExerciseFrequency(exerciseFrequency),
                    dailyActivityLevel: mapDailyActivityLevel(activityLevel),
                    cardioFitnessLevel: mapCardioFitnessLevel(selectedCardioFitness),
                    lengthUnitPreference: lengthUnitPreference,
                    weightUnitPreference: weightUnitPreference,
                    profileImageUrl: existing.profileImageUrl,
                    creationDate: existing.creationDate,
                    creationVersion: existing.creationVersion,
                    lastSignInDate: existing.lastSignInDate,
                    didCompleteOnboarding: true,
                    createdExerciseTemplateIds: existing.createdExerciseTemplateIds,
                    bookmarkedExerciseTemplateIds: existing.bookmarkedExerciseTemplateIds,
                    favouritedExerciseTemplateIds: existing.favouritedExerciseTemplateIds,
                    createdWorkoutTemplateIds: existing.createdWorkoutTemplateIds,
                    bookmarkedWorkoutTemplateIds: existing.bookmarkedWorkoutTemplateIds,
                    favouritedWorkoutTemplateIds: existing.favouritedWorkoutTemplateIds,
                    createdIngredientTemplateIds: existing.createdIngredientTemplateIds,
                    bookmarkedIngredientTemplateIds: existing.bookmarkedIngredientTemplateIds,
                    favouritedIngredientTemplateIds: existing.favouritedIngredientTemplateIds,
                    createdRecipeTemplateIds: existing.createdRecipeTemplateIds,
                    bookmarkedRecipeTemplateIds: existing.bookmarkedRecipeTemplateIds,
                    favouritedRecipeTemplateIds: existing.favouritedRecipeTemplateIds,
                    blockedUserIds: existing.blockedUserIds
                )

                try await performOperationWithTimeout {
                    try await userManager.saveUser(user: model, image: nil)
                }
                logManager.trackEvent(event: Event.profileSaveSuccess)
                navigationDestination = .expenditure
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
                            Button("Try Again") { onContinue() }
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

// MARK: - Previews

#Preview("Default - Ready to submit") {
    NavigationStack {
        OnboardingCardioFitnessView(
            gender: .male,
            dateOfBirth: Date(),
            height: 180,
            weight: 75,
            exerciseFrequency: .threeToFour,
            activityLevel: .moderate,
            lengthUnitPreference: .centimeters,
            weightUnitPreference: .kilograms
        )
    }
    .environment(UserManager(services: MockUserServices(user: .mock)))
    .environment(LogManager(services: [ConsoleService(printParameters: true)]))
    .previewEnvironment()
}

#Preview("Disabled - No selection") {
    NavigationStack {
        OnboardingCardioFitnessView(
                gender: .female,
                dateOfBirth: Date(),
                height: 165,
                weight: 60,
                exerciseFrequency: .oneToTwo,
                activityLevel: .light,
                lengthUnitPreference: .centimeters,
                weightUnitPreference: .kilograms
        )
    }
    .environment(UserManager(services: MockUserServices(user: .mock)))
    .environment(LogManager(services: [ConsoleService(printParameters: true)]))
    .previewEnvironment()
}

#Preview("Saving - Busy state") {
    NavigationStack {
        OnboardingCardioFitnessView(
            gender: .male,
            dateOfBirth: Date(),
            height: 190,
            weight: 90,
            exerciseFrequency: .daily,
            activityLevel: .active,
            lengthUnitPreference: .centimeters,
            weightUnitPreference: .kilograms
        )
    }
    .environment(UserManager(services: MockUserServices(user: .mock, delay: 3)))
    .environment(LogManager(services: [ConsoleService(printParameters: true)]))
    .previewEnvironment()
}

#Preview("Error - Retryable network error") {
    NavigationStack {
        OnboardingCardioFitnessView(
            gender: .male,
            dateOfBirth: Date(),
            height: 175,
            weight: 70,
            exerciseFrequency: .threeToFour,
            activityLevel: .moderate,
            lengthUnitPreference: .centimeters,
            weightUnitPreference: .kilograms
        )
    }
    .environment(UserManager(services: MockUserServices(user: .mock, showError: true)))
    .environment(LogManager(services: [ConsoleService(printParameters: true)]))
    .previewEnvironment()
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

private func mapCardioFitnessLevel(_ value: OnboardingCardioFitnessView.CardioFitnessLevel) -> ProfileCardioFitnessLevel {
    switch value {
    case .beginner: return .beginner
    case .novice: return .novice
    case .intermediate: return .intermediate
    case .advanced: return .advanced
    case .elite: return .elite
    }
}

// MARK: - Events

private extension OnboardingCardioFitnessView {
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
