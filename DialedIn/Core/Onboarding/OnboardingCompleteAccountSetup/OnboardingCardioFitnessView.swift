//
//  OnboardingCardioFitnessView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingCardioFitnessView: View {
    @Environment(DependencyContainer.self) private var container

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
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    var body: some View {
        List {
            cardioFitnessSection
        }
        .navigationTitle("Cardio Fitness")
        .toolbar {
            toolbarContent
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
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
    }
    
    private var cardioFitnessSection: some View {
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
                if let cardioFitnessLevel = selectedCardioFitness {
                    OnboardingExpenditureView(
                        gender: gender,
                        dateOfBirth: dateOfBirth,
                        height: height,
                        weight: weight,
                        exerciseFrequency: exerciseFrequency,
                        activityLevel: activityLevel,
                        lengthUnitPreference: lengthUnitPreference,
                        weightUnitPreference: weightUnitPreference,
                        selectedCardioFitness: cardioFitnessLevel
                    )
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!canSubmit)
            .buttonStyle(.glassProminent)
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
