//
//  ProgramTemplatePickerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ProgramTemplatePickerView: View {

    @State var presenter: ProgramTemplatePickerPresenter

    var body: some View {
            List {
                builtInTemplatesSection
                userTemplatesSection
            }
            .navigationTitle("Choose Program")
            .navigationBarTitleDisplayMode(.large)
            .scrollIndicators(.hidden)
            .toolbar {
                toolbarContent
            }
            .showModal(
                showModal: $presenter.isCreatingPlan,
                content: {
                    ProgressView(
                        "Creating Program..."
                    )
                    .padding()
                }
            )
    }
    
    private var builtInTemplatesSection: some View {
        Section {
            ForEach(presenter.builtInTemplates) { template in
                Button {
                    presenter.onProgramStartConfigPressed(template: template)
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
    
    private var userTemplatesSection: some View {
        Section {
            if let userId = presenter.uid {
                let userTemplates = presenter.userTemplates(for: userId)
                
                if userTemplates.isEmpty {
                    Text("No saved custom programs yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(userTemplates) { template in
                        Button {
                            presenter.onProgramStartConfigPressed(template: template)
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
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.navToCustomProgramBuilderView()
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.glassProminent)
        }
    }

}

extension CoreBuilder {
    func programTemplatePickerView(router: AnyRouter) -> some View {
        ProgramTemplatePickerView(
            presenter: ProgramTemplatePickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showProgramTemplatePickerView() {
        router.showScreen(.push) { router in
            builder.programTemplatePickerView(router: router)
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
