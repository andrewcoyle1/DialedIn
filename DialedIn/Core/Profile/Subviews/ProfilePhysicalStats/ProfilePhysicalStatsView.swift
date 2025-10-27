//
//  ProfilePhysicalStatsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct ProfilePhysicalStatsView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ProfilePhysicalStatsViewModel
        
    var body: some View {
        List {
            if let user = viewModel.currentUser {
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
        .sheet(isPresented: $viewModel.showLogWeightSheet) {
            LogWeightView(viewModel: LogWeightViewModel(interactor: CoreInteractor(container: container)))
        }
        .task {
            await viewModel.loadWeights()
            
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.showLogWeightSheet = true
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
                    value: viewModel.formatHeight(height, unit: user.lengthUnitPreference ?? .centimeters),
                    color: .blue
                )
            }
            
            if let weight = user.weightKilograms {
                metricCard(
                    icon: "scalemass",
                    label: "Current Weight",
                    value: viewModel.formatWeight(weight, unit: user.weightUnitPreference ?? .kilograms),
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
            if viewModel.weightHistory.isEmpty {
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
                ForEach(viewModel.weightHistory.prefix(5)) { entry in
                    weightEntryRow(entry, unit: user.weightUnitPreference ?? .kilograms)
                }
            }
        } header: {
            Text("Weight History")
        } footer: {
            if !viewModel.weightHistory.isEmpty {
                Text("Showing recent entries")
            }
        }
    }
    
    private func weightEntryRow(_ entry: WeightEntry, unit: WeightUnitPreference) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.formatWeight(entry.weightKg, unit: unit))
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
                    value: viewModel.formatExerciseFrequency(frequency),
                    color: .orange
                )
            }
            
            if let activity = user.dailyActivityLevel {
                metricCard(
                    icon: "figure.run",
                    label: "Daily Activity Level",
                    value: viewModel.formatActivityLevel(activity),
                    color: .red
                )
            }
            
            if let cardio = user.cardioFitnessLevel {
                metricCard(
                    icon: "heart.fill",
                    label: "Cardio Fitness Level",
                    value: viewModel.formatCardioFitness(cardio),
                    color: .pink
                )
            }
        }
    }
    
    private func bmiSection(_ user: UserModel) -> some View {
        Group {
            if let height = user.heightCentimeters, let weight = user.weightKilograms {
                let bmi = viewModel.calculateBMI(heightCm: height, weightKg: weight)
                let category = viewModel.getBMICategory(bmi)
                
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
}

#Preview {
    NavigationStack {
        ProfilePhysicalStatsView(viewModel: ProfilePhysicalStatsViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
    }
    .previewEnvironment()
}
