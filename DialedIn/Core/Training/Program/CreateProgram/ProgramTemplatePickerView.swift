//
//  ProgramTemplatePickerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramTemplatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProgramTemplateManager.self) private var programTemplateManager
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(AuthManager.self) private var authManager
    
    @State private var selectedTemplate: ProgramTemplateModel?
    @State private var showStartDate = false
    @State private var startDate = Date()
    @State private var customPlanName = ""
    @State private var isCreatingPlan = false
    
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack {
            List {
                builtInTemplatesSection
                userTemplatesSection
                customOptionSection
            }
            .navigationTitle("Choose Program")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .navigationDestination(item: $selectedTemplate) { template in
                ProgramStartConfigView(
                    template: template,
                    onStart: { startDate, endDate, customName in
                        Task {
                            await createPlanFromTemplate(template, startDate: startDate, endDate: endDate, customName: customName)
                        }
                    }
                )
            }
            .showCustomAlert(alert: $showAlert)
            .showModal(showModal: $isCreatingPlan, content: {
                ProgressView("Creating Program...")
                    .padding()
            })
            
        }
    }
    
    private var userTemplatesSection: some View {
        Section {
            if let userId = authManager.auth?.uid {
                // Access templates directly to trigger observation
                let allTemplates = programTemplateManager.templates
                let userTemplates = allTemplates
                    .filter { $0.authorId == userId && !programTemplateManager.isBuiltIn($0) }
                    .sorted { $0.modifiedAt > $1.modifiedAt }
                
                if userTemplates.isEmpty {
                    Text("No saved custom programs yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(userTemplates) { template in
                        Button {
                            selectedTemplate = template
                        } label: {
                            ProgramTemplateCard(template: template)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                Text("Sign in to view your saved programs")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Your Programs")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
    }
    
    private var builtInTemplatesSection: some View {
        Section {
            ForEach(programTemplateManager.getBuiltInTemplates()) { template in
                Button {
                    selectedTemplate = template
                } label: {
                    ProgramTemplateCard(template: template)
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Recommended Programs")
        } footer: {
            Text("These programs are designed by certified trainers for different fitness levels and goals.")
        }
    }
    
    private var customOptionSection: some View {
        Section {
            NavigationLink {
                CustomProgramBuilderView()
            } label: {
                Label("Create Custom Program", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Custom")
        }
    }
    
    private func createPlanFromTemplate(_ template: ProgramTemplateModel, startDate: Date, endDate: Date?, customName: String?) async {
        guard let userId = authManager.auth?.uid else { return }
        
        isCreatingPlan = true
        
        do {
            _ = try await trainingPlanManager.createPlanFromTemplate(
                template,
                startDate: startDate,
                endDate: endDate,
                userId: userId,
                planName: customName,
                workoutTemplateManager: workoutTemplateManager
            )
            dismiss()
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
        
        isCreatingPlan = false
    }
}

#Preview {
    ProgramTemplatePickerView()
        .previewEnvironment()
}
