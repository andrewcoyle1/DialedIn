//
//  OnboardingCalorieFloorView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingCalorieFloorView: View {

    @State var presenter: OnboardingCalorieFloorPresenter

    var delegate: OnboardingCalorieFloorDelegate

    var body: some View {
        List {
            if let daysPerWeek = presenter.trainingDaysPerWeek {
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
                        Image(systemName: presenter.selectedFloor == type ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(presenter.selectedFloor == type ? .accent : .secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { presenter.selectedFloor = type }
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
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.navigateToTrainingType(dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedFloor == nil)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingCalorieFloorView(
            router: router,
            delegate: OnboardingCalorieFloorDelegate(
                dietPlanBuilder: .mock
            )
        )
    }
    .previewEnvironment()
}
