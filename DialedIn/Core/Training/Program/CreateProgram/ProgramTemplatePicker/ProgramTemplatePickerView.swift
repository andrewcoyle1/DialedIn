//
//  ProgramTemplatePickerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramTemplatePickerView: View {
    @Environment(CoreBuilder.self) private var builder
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: ProgramTemplatePickerViewModel

    @Binding var path: [TabBarPathOption]

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
            .navigationDestination(item: $viewModel.selectedTemplate) { template in
                builder.programStartConfigView(
                    delegate: ProgramStartConfigViewDelegate(
                        path: $path,
                        template: template,
                        onStart: { startDate, endDate, customName in
                            Task {
                                await viewModel.createPlanFromTemplate(
                                    template,
                                    startDate: startDate,
                                    endDate: endDate,
                                    customName: customName,
                                    onDismiss: {
                                        dismiss()
                                    }
                                )
                            }
                        }
                    )
                )
            }
            .showCustomAlert(alert: $viewModel.showAlert)
            .showModal(showModal: $viewModel.isCreatingPlan, content: {
                ProgressView("Creating Program...")
                    .padding()
            })
            
        }
    }
    
    private var userTemplatesSection: some View {
        Section {
            if let userId = viewModel.uid {
                // Access templates directly to trigger observation
                let allTemplates = viewModel.programTemplates
                let userTemplates = allTemplates
                    .filter { $0.authorId == userId && !viewModel.isBuiltIn($0) }
                    .sorted { $0.modifiedAt > $1.modifiedAt }
                
                if userTemplates.isEmpty {
                    Text("No saved custom programs yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(userTemplates) { template in
                        Button {
                            viewModel.selectedTemplate = template
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
            ForEach(viewModel.programTemplates) { template in
                Button {
                    viewModel.selectedTemplate = template
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
            Button {
                viewModel.navToCustomProgramBuilderView(path: $path
                )
            } label: {
                Label("Create Custom Program", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Custom")
        }
    }
}

#Preview {
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.programTemplatePickerView(path: $path)
    .previewEnvironment()
}
