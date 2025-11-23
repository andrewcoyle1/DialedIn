//
//  OnboardingCalorieFloorView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingCalorieFloorViewDelegate {
    let dietPlanBuilder: DietPlanBuilder
}

struct OnboardingCalorieFloorView: View {

    @State var viewModel: OnboardingCalorieFloorViewModel

    var delegate: OnboardingCalorieFloorViewDelegate

    var body: some View {
        List {
            if let daysPerWeek = viewModel.trainingDaysPerWeek {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Based on your \(daysPerWeek)-day training program")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .removeListRowFormatting()
                    .padding(.horizontal)
                }
            }
            
            ForEach(CalorieFloor.allCases) { type in
                Section {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(type.description)
                                .font(.headline)
                            Text(type.detailedDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: viewModel.selectedFloor == type ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(viewModel.selectedFloor == type ? .accent : .secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel.selectedFloor = type }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Calorie floor")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.navigateToTrainingType(dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedFloor == nil)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingCalorieFloorView(
            router: router,
            delegate: OnboardingCalorieFloorViewDelegate(
                dietPlanBuilder: .mock
            )
        )
    }
    .previewEnvironment()
}
