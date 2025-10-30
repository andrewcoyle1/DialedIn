//
//  ProfilePhysicalMetricsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

struct ProfilePhysicalMetricsView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ProfilePhysicalMetricsViewModel
    
    var body: some View {
        Section {
            if let user = viewModel.currentUser {
                NavigationLink {
                    ProfilePhysicalStatsView(viewModel: ProfilePhysicalStatsViewModel(interactor: CoreInteractor(container: container)))
                } label: {
                    
                        VStack(spacing: 8) {
                            if let height = user.heightCentimeters {
                                MetricRow(
                                    label: "Height",
                                    value: viewModel.formatHeight(height, unit: user.lengthUnitPreference ?? .centimeters)
                                )
                            }
                            
                            if let weight = user.weightKilograms {
                                MetricRow(
                                    label: "Weight",
                                    value: viewModel.formatWeight(weight, unit: user.weightUnitPreference ?? .kilograms)
                                )
                            }
                            
                            if let height = user.heightCentimeters, let weight = user.weightKilograms {
                                let bmi = viewModel.calculateBMI(heightCm: height, weightKg: weight)
                                MetricRow(
                                    label: "BMI",
                                    value: String(format: "%.1f", bmi)
                                )
                            }
                            
                            if let frequency = user.exerciseFrequency {
                                MetricRow(
                                    label: "Exercise Frequency",
                                    value: viewModel.formatExerciseFrequency(frequency)
                                )
                            }
                            
                            if let activity = user.dailyActivityLevel {
                                MetricRow(
                                    label: "Activity Level",
                                    value: viewModel.formatActivityLevel(activity)
                                )
                            }
                            
                            if let cardio = user.cardioFitnessLevel {
                                MetricRow(
                                    label: "Cardio Fitness",
                                    value: viewModel.formatCardioFitness(cardio)
                                )
                            }
                        }
                    
                }
            }
        } header: {
            HStack(spacing: 8) {
                Image(systemName: "figure.walk")
                    .font(.title3)
                    .foregroundStyle(.accent)
                    .frame(width: 28)
                
                Text("Physical Metrics")
                    .font(.headline)
                
                Spacer()
            }
        }
    }
}

#Preview {
    List {
        ProfilePhysicalMetricsView(viewModel: ProfilePhysicalMetricsViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
    }
}
