//
//  ProfileView+Goals.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import CustomRouting

struct ProfileGoalSection: View {

    @State var viewModel: ProfileGoalSectionViewModel

    var body: some View {
        Section {
            if let goal = viewModel.currentGoal,
               let user = viewModel.currentUser {
                Button {
                    viewModel.navToProfileGoals()
                } label: {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(goal.objective.description.capitalized)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        if let currentWeight = user.weightKilograms {
                            let unit = user.weightUnitPreference ?? .kilograms
                            HStack(spacing: 8) {
                                Text(viewModel.formatWeight(currentWeight, unit: unit))
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(viewModel.formatWeight(goal.targetWeightKg, unit: unit))
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        
                        if goal.weeklyChangeKg > 0 {
                            let unit = user.weightUnitPreference ?? .kilograms
                            Text("Weekly rate: \(viewModel.formatWeight(goal.weeklyChangeKg, unit: unit))/week")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        
                        // Progress indicator
                        if let currentWeight = user.weightKilograms, goal.weeklyChangeKg > 0 {
                            let progress = goal.calculateProgress(currentWeight: currentWeight)
                            let weeks = Int(ceil(abs(goal.targetWeightKg - currentWeight) / goal.weeklyChangeKg))
                            
                            Divider()
                            
                            HStack {
                                Text("Progress: \(Int(progress * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("~\(weeks) weeks")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } else if viewModel.currentUser != nil {
                Button {
                    viewModel.showSetGoalSheet = true
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Define your weight goal to start tracking progress")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundStyle(.green)
                            Text("Get Started")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        } header: {
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.title3)
                    .foregroundStyle(.green)
                    .frame(width: 28)
                
                Text("Current Goal")
                    .font(.headline)
                
                Spacer()
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.profileGoalSection(router: router)
    }
    .previewEnvironment()
}
