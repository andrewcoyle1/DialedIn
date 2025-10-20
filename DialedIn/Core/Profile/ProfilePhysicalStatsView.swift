//
//  ProfilePhysicalStatsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct ProfilePhysicalStatsView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(UserWeightManager.self) private var weightManager
    
    @State private var showLogWeightSheet: Bool = false
    
    var body: some View {
        List {
            if let user = userManager.currentUser {
                bodyMetricsSection(user)
                weightHistorySection(user)
                fitnessMetricsSection(user)
                bmiSection(user)
            } else {
                Section {
                    Text("No profile data available")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Physical Metrics")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showLogWeightSheet) {
            LogWeightView()
        }
        .task {
            if let user = userManager.currentUser {
                try? await weightManager.getWeightHistory(userId: user.userId, limit: 5)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showLogWeightSheet = true
            } label: {
                Label("Log Weight", systemImage: "plus.circle.fill")
            }
        }
    }
    
    private func bodyMetricsSection(_ user: UserModel) -> some View {
        Section("Body Metrics") {
            if let height = user.heightCentimeters {
                metricCard(
                    icon: "ruler",
                    label: "Height",
                    value: formatHeight(height, unit: user.lengthUnitPreference ?? .centimeters),
                    color: .blue
                )
            }
            
            if let weight = user.weightKilograms {
                metricCard(
                    icon: "scalemass",
                    label: "Current Weight",
                    value: formatWeight(weight, unit: user.weightUnitPreference ?? .kilograms),
                    color: .green
                )
            }
            
            if let dob = user.dateOfBirth {
                let age = Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
                metricCard(
                    icon: "calendar",
                    label: "Age",
                    value: "\(age) years",
                    color: .purple
                )
            }
            
            if let gender = user.gender {
                metricCard(
                    icon: "person",
                    label: "Gender",
                    value: gender.description,
                    color: .pink
                )
            }
        }
    }
    
    private func weightHistorySection(_ user: UserModel) -> some View {
        Section {
            if weightManager.weightHistory.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "scalemass")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No Weight Entries")
                        .font(.headline)
                    Text("Tap the + button to log your first weight entry")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(weightManager.weightHistory.prefix(5)) { entry in
                    weightEntryRow(entry, unit: user.weightUnitPreference ?? .kilograms)
                }
            }
        } header: {
            Text("Weight History")
        } footer: {
            if !weightManager.weightHistory.isEmpty {
                Text("Showing recent entries")
            }
        }
    }
    
    private func weightEntryRow(_ entry: WeightEntry, unit: WeightUnitPreference) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatWeight(entry.weightKg, unit: unit))
                    .font(.headline)
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if let notes = entry.notes, !notes.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
    
    private func fitnessMetricsSection(_ user: UserModel) -> some View {
        Section("Fitness Profile") {
            if let frequency = user.exerciseFrequency {
                metricCard(
                    icon: "figure.walk",
                    label: "Exercise Frequency",
                    value: formatExerciseFrequency(frequency),
                    color: .orange
                )
            }
            
            if let activity = user.dailyActivityLevel {
                metricCard(
                    icon: "figure.run",
                    label: "Daily Activity Level",
                    value: formatActivityLevel(activity),
                    color: .red
                )
            }
            
            if let cardio = user.cardioFitnessLevel {
                metricCard(
                    icon: "heart.fill",
                    label: "Cardio Fitness Level",
                    value: formatCardioFitness(cardio),
                    color: .pink
                )
            }
        }
    }
    
    private func bmiSection(_ user: UserModel) -> some View {
        Group {
            if let height = user.heightCentimeters, let weight = user.weightKilograms {
                let bmi = calculateBMI(heightCm: height, weightKg: weight)
                let category = getBMICategory(bmi)
                
                Section("Body Mass Index") {
                    VStack(spacing: 8) {
                        Text(String(format: "%.1f", bmi))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(category.color)
                        
                        Text(category.name)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    
                    Text(category.description)
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BMI Categories")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        bmiCategoryRow("Underweight", "< 18.5")
                        bmiCategoryRow("Normal", "18.5 - 24.9")
                        bmiCategoryRow("Overweight", "25.0 - 29.9")
                        bmiCategoryRow("Obese", "≥ 30.0")
                    }
                }
            }
        }
    }
    
    private func metricCard(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
    }
    
    private func bmiCategoryRow(_ name: String, _ range: String) -> some View {
        HStack {
            Text(name)
                .font(.caption2)
            Spacer()
            Text(range)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatHeight(_ heightCm: Double, unit: LengthUnitPreference) -> String {
        switch unit {
        case .centimeters:
            return String(format: "%.0f cm", heightCm)
        case .inches:
            let totalInches = heightCm / 2.54
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            return "\(feet)' \(inches)\""
        }
    }
    
    private func formatWeight(_ weightKg: Double, unit: WeightUnitPreference) -> String {
        switch unit {
        case .kilograms:
            return String(format: "%.1f kg", weightKg)
        case .pounds:
            let pounds = weightKg * 2.20462
            return String(format: "%.1f lbs", pounds)
        }
    }
    
    private func calculateBMI(heightCm: Double, weightKg: Double) -> Double {
        let heightM = heightCm / 100
        return weightKg / (heightM * heightM)
    }
    
    private func getBMICategory(_ bmi: Double) -> (name: String, color: Color, description: String) {
        if bmi < 18.5 {
            return ("Underweight", .blue, "A BMI below 18.5 may indicate underweight. Consider consulting a healthcare provider.")
        } else if bmi < 25.0 {
            return ("Normal", .green, "A BMI between 18.5 and 24.9 is considered healthy weight range.")
        } else if bmi < 30.0 {
            return ("Overweight", .orange, "A BMI between 25.0 and 29.9 may indicate overweight. Consider a balanced diet and regular exercise.")
        } else {
            return ("Obese", .red, "A BMI of 30.0 or higher may indicate obesity. Consider consulting a healthcare provider for guidance.")
        }
    }
    
    private func formatExerciseFrequency(_ frequency: ProfileExerciseFrequency) -> String {
        switch frequency {
        case .never: return "Never"
        case .oneToTwo: return "1-2 times/week"
        case .threeToFour: return "3-4 times/week"
        case .fiveToSix: return "5-6 times/week"
        case .daily: return "Daily"
        }
    }
    
    private func formatActivityLevel(_ level: ProfileDailyActivityLevel) -> String {
        switch level {
        case .sedentary: return "Sedentary"
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .active: return "Active"
        case .veryActive: return "Very Active"
        }
    }
    
    private func formatCardioFitness(_ level: ProfileCardioFitnessLevel) -> String {
        switch level {
        case .beginner: return "Beginner"
        case .novice: return "Novice"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .elite: return "Elite"
        }
    }
}

#Preview {
    NavigationStack {
        ProfilePhysicalStatsView()
    }
    .environment(
        UserManager(
            services: MockUserServices(
                user: UserModel(
                    userId: UUID().uuidString,
                    email: "user@example.com",
                    isAnonymous: false,
                    firstName: "Alice",
                    lastName: "Cooper",
                    dateOfBirth: Calendar.current.date(from: DateComponents(year: 1990, month: 5, day: 15)),
                    gender: .female,
                    heightCentimeters: 165,
                    weightKilograms: 60,
                    exerciseFrequency: .threeToFour,
                    dailyActivityLevel: .moderate,
                    cardioFitnessLevel: .intermediate,
                    lengthUnitPreference: .centimeters,
                    weightUnitPreference: .kilograms
                )
            )
        )
    )
    .previewEnvironment()
}
