//
//  GenericTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

struct GenericTemplateListView<Template: TemplateModel>: View {
    @State var viewModel: GenericTemplateListViewModel<Template>
    let configuration: TemplateListConfiguration<Template>
    let supportsRefresh: Bool
    let templateIdsOverride: [String]?
    
    @Environment(\.dismiss) private var dismiss
    
    init(
        viewModel: GenericTemplateListViewModel<Template>,
        configuration: TemplateListConfiguration<Template>,
        supportsRefresh: Bool = false,
        templateIdsOverride: [String]? = nil
    ) {
        self.viewModel = viewModel
        self.configuration = configuration
        self.supportsRefresh = supportsRefresh
        self.templateIdsOverride = templateIdsOverride
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.templates.isEmpty {
                    ContentUnavailableView(
                        configuration.emptyStateTitle,
                        systemImage: configuration.emptyStateIcon,
                        description: Text(configuration.emptyStateDescription)
                    )
                } else {
                    List {
                        ForEach(viewModel.templates) { template in
                            CustomListCellView(
                                imageName: template.imageURL,
                                title: template.name,
                                subtitle: template.description
                            )
                            .anyButton(.highlight) {
                                viewModel.path.append(viewModel.navigationDestination(for: template))
                            }
                            .removeListRowFormatting()
                        }
                    }
                }
            }
            .navigationTitle(configuration.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .task {
                await viewModel.loadTemplates(templateIds: templateIdsOverride ?? viewModel.templateIds)
            }
            .if(supportsRefresh) { view in
                view.refreshable {
                    await viewModel.loadTemplates(templateIds: templateIdsOverride ?? viewModel.templateIds)
                }
            }
            .showCustomAlert(alert: $viewModel.showAlert)
            .navDestinationForTabBarModule(path: $viewModel.path)
        }
    }
}

// Helper extension for conditional view modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
