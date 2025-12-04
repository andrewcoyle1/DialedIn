//
//  AddGoalView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct AddGoalView: View {

    @State var presenter: AddGoalPresenter

    init(presenter: AddGoalPresenter, delegate: AddGoalDelegate) {
        self.presenter = presenter
        presenter.addTrainingPlan(delegate.plan)
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Goal Type", selection: $presenter.selectedType) {
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
                    TextField("Value", value: $presenter.targetValue, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text(presenter.selectedType.unit)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Target")
            }
            
            Section {
                Toggle("Set Target Date", isOn: $presenter.hasTargetDate)
                
                if presenter.hasTargetDate {
                    DatePicker("Target Date", selection: $presenter.targetDate, displayedComponents: .date)
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
                    presenter.onDismissPressed()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    Task {
                        await presenter.addGoal()
                    }
                }
                .disabled(presenter.isSaving || presenter.targetValue <= 0)
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.addGoalView(router: router, delegate: AddGoalDelegate(plan: .mock))
    }
}
