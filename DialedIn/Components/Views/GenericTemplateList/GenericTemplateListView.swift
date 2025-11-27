//
//  GenericTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

struct GenericTemplateListView<Template: TemplateModel>: View {

    @Environment(\.dismiss) private var dismiss

    @State var presenter: GenericTemplateListPresenter<Template>
    let configuration: TemplateListConfiguration<Template>
    let supportsRefresh: Bool
    let templateIdsOverride: [String]?

    init(
        presenter: GenericTemplateListPresenter<Template>,
        configuration: TemplateListConfiguration<Template>,
        supportsRefresh: Bool = false,
        templateIdsOverride: [String]? = nil
    ) {
        self.presenter = presenter
        self.configuration = configuration
        self.supportsRefresh = supportsRefresh
        self.templateIdsOverride = templateIdsOverride
    }
    
    var body: some View {
        Group {
            if presenter.isLoading {
                ProgressView()
            } else if presenter.templates.isEmpty {
                ContentUnavailableView(
                    configuration.emptyStateTitle,
                    systemImage: configuration.emptyStateIcon,
                    description: Text(configuration.emptyStateDescription)
                )
            } else {
                List {
                    ForEach(presenter.templates) { template in
                        CustomListCellView(
                            imageName: template.imageURL,
                            title: template.name,
                            subtitle: template.description
                        )
                        .anyButton(.highlight) {
//                            
//                            presenter.path.append(presenter.navigationDestination(for: template))
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
            await presenter.loadTemplates(templateIds: templateIdsOverride ?? presenter.templateIds)
        }
        .if(supportsRefresh) { view in
            view.refreshable {
                await presenter.loadTemplates(templateIds: templateIdsOverride ?? presenter.templateIds)
            }
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
