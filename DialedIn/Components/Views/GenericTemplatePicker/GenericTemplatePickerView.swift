//
//  GenericTemplatePickerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI

// swiftlint:disable:next class_delegate_protocol
protocol GenericTemplateListDelegate {
    var onSelect: (any TemplateModel) -> Void { get }
    var onCancel: () -> Void { get }
}

struct GenericTemplatePickerView<Template: TemplateModel>: View {
    @State var presenter: GenericTemplatePickerPresenter<Template>
    
    init(presenter: GenericTemplatePickerPresenter<Template>, delegate: GenericTemplateListDelegate) {
        self.presenter = presenter
        self.delegate = delegate
    }

    let delegate: GenericTemplateListDelegate

    var body: some View {
        List {
            if presenter.isLoading {
                Section { ProgressView().frame(maxWidth: .infinity) }
            }
            if !presenter.userResults.isEmpty {
                Section {
                    ForEach(presenter.userResults, id: \.id) { template in
                        CustomListCellView(
                            imageName: template.imageURL,
                            title: template.name,
                            subtitle: template.description
                        )
                        .anyButton(.highlight) {
                            presenter.onSelect(template)
                        }
                        .removeListRowFormatting()
                    }
                } header: {
                    Text(presenter.configuration.userSectionTitle)
                }
            }
            if !presenter.officialResults.isEmpty {
                Section {
                    ForEach(presenter.officialResults, id: \.id) { template in
                        CustomListCellView(
                            imageName: template.imageURL,
                            title: template.name,
                            subtitle: template.description
                        )
                        .anyButton(.highlight) {
                            presenter.onSelect(template)
                        }
                        .removeListRowFormatting()
                    }
                } header: {
                    Text(presenter.configuration.officialSectionTitle)
                }
            }
            if !presenter.isLoading && presenter.userResults.isEmpty && presenter.officialResults.isEmpty {
                Section {
                    Text(presenter.configuration.emptyStateMessage)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(presenter.configuration.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { 
                Button("Cancel", action: presenter.onCancel) 
            }
        }
        .searchable(text: $presenter.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) {
            Task { await presenter.runSearch() }
        }
        .task {
            await presenter.loadTopTemplates()
        }
    }
}
