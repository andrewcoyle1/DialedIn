//
//  AddGoalView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct AddGoalView: View {
    @State var viewModel: AddGoalViewModel
    @Environment(\.dismiss) private var dismiss
        
    init(viewModel: AddGoalViewModel, plan: TrainingPlan) {
        self.viewModel = viewModel
        viewModel.addTrainingPlan(plan)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Goal Type", selection: $viewModel.selectedType) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            Text(type.description).tag(type)
                        }
                    }
                } header: {
                    Text("Type")
                }
                
                Section {
                    HStack {
                        Text("Target")
                        Spacer()
                        TextField("Value", value: $viewModel.targetValue, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text(viewModel.selectedType.unit)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Target")
                }
                
                Section {
                    Toggle("Set Target Date", isOn: $viewModel.hasTargetDate)
                    
                    if viewModel.hasTargetDate {
                        DatePicker("Target Date", selection: $viewModel.targetDate, displayedComponents: .date)
                    }
                } header: {
                    Text("Timeline")
                }
            }
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            await viewModel.addGoal(onDismiss: { dismiss() })
                        }
                    }
                    .disabled(viewModel.isSaving || viewModel.targetValue <= 0)
                }
            }
        }
    }
}

#Preview {
    AddGoalView(viewModel: AddGoalViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), plan: TrainingPlan.mock)
        .previewEnvironment()
}
