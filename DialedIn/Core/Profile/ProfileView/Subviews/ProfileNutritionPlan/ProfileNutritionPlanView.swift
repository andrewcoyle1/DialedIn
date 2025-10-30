//
//  ProfileNutritionPlanView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

struct ProfileNutritionPlanView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ProfileNutritionPlanViewModel
    
    var body: some View {
        Section {
            if let plan = viewModel.currentDietPlan {
                NavigationLink {
                    ProfileNutritionDetailView(viewModel: ProfileNutritionDetailViewModel(interactor: CoreInteractor(container: container)))
                } label: {
                    VStack(spacing: 8) {
                        MetricRow(
                            label: "TDEE Estimate",
                            value: "\(Int(plan.tdeeEstimate)) kcal/day"
                        )
                        
                        MetricRow(
                            label: "Diet Type",
                            value: plan.preferredDiet.capitalized
                        )
                        
                        MetricRow(
                            label: "Training Focus",
                            value: plan.trainingType.replacingOccurrences(of: "_", with: " ").capitalized
                        )
                        
                        // Average daily calories
                        let avgCalories = plan.days.reduce(0.0) { $0 + $1.calories } / Double(plan.days.count)
                        MetricRow(
                            label: "Avg Daily Calories",
                            value: "\(Int(avgCalories)) kcal"
                        )
                        
                        // Average macros
                        let avgProtein = plan.days.reduce(0.0) { $0 + $1.proteinGrams } / Double(plan.days.count)
                        let avgCarbs = plan.days.reduce(0.0) { $0 + $1.carbGrams } / Double(plan.days.count)
                        let avgFat = plan.days.reduce(0.0) { $0 + $1.fatGrams } / Double(plan.days.count)
                        
                        HStack(spacing: 16) {
                            VStack(spacing: 2) {
                                Text("\(Int(avgProtein))g")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("Protein")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            VStack(spacing: 2) {
                                Text("\(Int(avgCarbs))g")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("Carbs")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            VStack(spacing: 2) {
                                Text("\(Int(avgFat))g")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("Fat")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        } header: {
            HStack(spacing: 8) {
                Image(systemName: "fork.knife")
                    .font(.title3)
                    .foregroundStyle(.orange)
                    .frame(width: 28)
                
                Text("Nutrition Plan")
                    .font(.headline)
                
                Spacer()
            }
        }
    }
}

#Preview {
    ProfileNutritionPlanView(viewModel: ProfileNutritionPlanViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
}
