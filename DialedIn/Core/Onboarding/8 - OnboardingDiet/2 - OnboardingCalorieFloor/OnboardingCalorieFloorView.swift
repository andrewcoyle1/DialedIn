//
//  OnboardingCalorieFloorView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingCalorieFloorViewDelegate {
    var path: Binding<[OnboardingPathOption]>
    let dietPlanBuilder: DietPlanBuilder
}

struct OnboardingCalorieFloorView: View {

    @Environment(CoreBuilder.self) private var builder

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
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            builder.devSettingsView()
        }
        #endif
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.navigateToTrainingType(path: delegate.path, dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedFloor == nil)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.onboardingCalorieFloorView(
            delegate: OnboardingCalorieFloorViewDelegate(
                path: $path,
                dietPlanBuilder: .mock
            )
        )
    }
    .previewEnvironment()
}
