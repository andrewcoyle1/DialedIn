//
//  OnboardingTrainingReviewView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

struct OnboardingTrainingReviewView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingTrainingReviewViewModel
    @Binding var path: [OnboardingPathOption]
    var trainingProgramBuilder: TrainingProgramBuilder

    var body: some View {
        List {
            if let recommendedTemplate = viewModel.recommendedTemplate {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recommended Program")
                            .font(.headline)
                        Text(recommendedTemplate.name)
                            .font(.title2)
                            .bold()
                        Text(recommendedTemplate.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                    .removeListRowFormatting()
                    .padding(.horizontal)
                } header: {
                    Text("Your Program")
                }
            }
            
            Section {
                summaryRow(title: "Experience Level", value: trainingProgramBuilder.experienceLevel?.description ?? "Not set")
                if let days = trainingProgramBuilder.targetDaysPerWeek {
                    summaryRow(title: "Training Days", value: "\(days) per week")
                }
                summaryRow(title: "Split Type", value: trainingProgramBuilder.splitType?.description ?? "Not set")
                if !trainingProgramBuilder.weeklySchedule.isEmpty {
                    let days = trainingProgramBuilder.weeklySchedule.sorted().map { weekdayName($0) }.joined(separator: ", ")
                    summaryRow(title: "Schedule", value: days)
                }
                if !trainingProgramBuilder.availableEquipment.isEmpty {
                    let equipment = trainingProgramBuilder.availableEquipment.map { $0.description }.joined(separator: ", ")
                    summaryRow(title: "Equipment", value: equipment)
                }
            } header: {
                Text("Summary")
            }
        }
        .navigationTitle("Review Program")
        .toolbar {
            toolbarContent
        }
        .showModal(showModal: $viewModel.isLoading) {
            ProgressView("Creating your program...")
                .padding()
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(
                viewModel: DevSettingsViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
        }
        #endif
        .screenAppearAnalytics(name: "TrainingReview")
        .onFirstAppear {
            viewModel.loadRecommendation(builder: trainingProgramBuilder)
        }
    }
    
    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
    
    private func weekdayName(_ dayNumber: Int) -> String {
        switch dayNumber {
        case 1: return "Sun"
        case 2: return "Mon"
        case 3: return "Tue"
        case 4: return "Wed"
        case 5: return "Thu"
        case 6: return "Fri"
        case 7: return "Sat"
        default: return ""
        }
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
                viewModel.createPlanAndContinue(path: $path, builder: trainingProgramBuilder)
            } label: {
                Text("Create Program")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.recommendedTemplate == nil || viewModel.isLoading)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        OnboardingTrainingReviewView(
            viewModel: OnboardingTrainingReviewViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ),
            path: $path,
            trainingProgramBuilder: TrainingProgramBuilder(
                experienceLevel: .intermediate,
                targetDaysPerWeek: 4,
                splitType: .upperLower,
                weeklySchedule: [2, 4, 6, 7],
                availableEquipment: [.barbell, .dumbbell]
            )
        )
    }
    .previewEnvironment()
}
