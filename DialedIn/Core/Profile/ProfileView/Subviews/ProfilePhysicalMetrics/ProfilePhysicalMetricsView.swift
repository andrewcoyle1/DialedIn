//
//  ProfilePhysicalMetricsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ProfilePhysicalMetricsView: View {
    
    @State var presenter: ProfilePhysicalMetricsPresenter

    var body: some View {
        Section {
            if let user = presenter.currentUser {
                Button {
                    presenter.navToPhysicalStats()
                } label: {

                        VStack(spacing: 8) {
                            if let height = user.heightCentimeters {
                                MetricRow(
                                    label: "Height",
                                    value: presenter.formatHeight(height, unit: user.lengthUnitPreference ?? .centimeters)
                                )
                            }
                            
                            if let weight = user.weightKilograms {
                                MetricRow(
                                    label: "Weight",
                                    value: presenter.formatWeight(weight, unit: user.weightUnitPreference ?? .kilograms)
                                )
                            }
                            
                            if let height = user.heightCentimeters, let weight = user.weightKilograms {
                                let bmi = presenter.calculateBMI(heightCm: height, weightKg: weight)
                                MetricRow(
                                    label: "BMI",
                                    value: String(format: "%.1f", bmi)
                                )
                            }
                            
                            if let frequency = user.exerciseFrequency {
                                MetricRow(
                                    label: "Exercise Frequency",
                                    value: presenter.formatExerciseFrequency(frequency)
                                )
                            }
                            
                            if let activity = user.dailyActivityLevel {
                                MetricRow(
                                    label: "Activity Level",
                                    value: presenter.formatActivityLevel(activity)
                                )
                            }
                            
                            if let cardio = user.cardioFitnessLevel {
                                MetricRow(
                                    label: "Cardio Fitness",
                                    value: presenter.formatCardioFitness(cardio)
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

extension CoreBuilder {
    func profilePhysicalMetricsView(router: AnyRouter) -> some View {
        ProfilePhysicalMetricsView(
            presenter: ProfilePhysicalMetricsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        List {
            builder.profilePhysicalMetricsView(router: router)
        }
    }
}
