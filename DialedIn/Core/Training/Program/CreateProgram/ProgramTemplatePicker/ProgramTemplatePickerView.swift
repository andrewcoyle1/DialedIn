//
//  ProgramTemplatePickerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import CustomRouting

struct ProgramTemplatePickerView: View {

    @State var viewModel: ProgramTemplatePickerViewModel

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
                viewModel.dismissScreen()
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
                viewModel.navToCustomProgramBuilderView()
            } label: {
                Label("Create Custom Program", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Custom")
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.programTemplatePickerView(router: router)
    }
    .previewEnvironment()
}
