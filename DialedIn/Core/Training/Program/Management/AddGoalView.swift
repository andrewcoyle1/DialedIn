//
//  AddGoalView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    
    let plan: TrainingPlan
    
    @State private var selectedType: GoalType = .consistency
    @State private var targetValue: Double = 12
    @State private var hasTargetDate = true
    @State private var targetDate = Date()
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Goal Type", selection: $selectedType) {
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
                        TextField("Value", value: $targetValue, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text(selectedType.unit)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Target")
                }
                
                Section {
                    Toggle("Set Target Date", isOn: $hasTargetDate)
                    
                    if hasTargetDate {
                        DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
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
                            await addGoal()
                        }
                    }
                    .disabled(isSaving || targetValue <= 0)
                }
            }
        }
    }
    
    private func addGoal() async {
        isSaving = true
        defer { isSaving = false }
        
        let goal = TrainingGoal(
            type: selectedType,
            targetValue: targetValue,
            currentValue: 0,
            targetDate: hasTargetDate ? targetDate : nil
        )
        
        do {
            try await trainingPlanManager.addGoal(goal)
            dismiss()
        } catch {
            print("Error adding goal: \(error)")
        }
    }
}

#Preview {
    AddGoalView(plan: TrainingPlan.mock)
        .previewEnvironment()
}
