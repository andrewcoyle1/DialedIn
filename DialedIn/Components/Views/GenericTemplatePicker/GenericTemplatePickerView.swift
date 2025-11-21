//
//  GenericTemplatePickerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI

// swiftlint:disable:next class_delegate_protocol
protocol GenericTemplateListViewDelegate {
    var onSelect: (any TemplateModel) -> Void { get }
    var onCancel: () -> Void { get }
}

struct GenericTemplatePickerView<Template: TemplateModel>: View {
    @State var viewModel: GenericTemplatePickerViewModel<Template>
    
    init(viewModel: GenericTemplatePickerViewModel<Template>, delegate: GenericTemplateListViewDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }

    let delegate: GenericTemplateListViewDelegate

    var body: some View {
        List {
            if viewModel.isLoading {
                Section { ProgressView().frame(maxWidth: .infinity) }
            }
            if !viewModel.userResults.isEmpty {
                Section {
                    ForEach(viewModel.userResults, id: \.id) { template in
                        CustomListCellView(
                            imageName: template.imageURL,
                            title: template.name,
                            subtitle: template.description
                        )
                        .anyButton(.highlight) {
                            viewModel.onSelect(template)
                        }
                        .removeListRowFormatting()
                    }
                } header: {
                    Text(viewModel.configuration.userSectionTitle)
                }
            }
            if !viewModel.officialResults.isEmpty {
                Section {
                    ForEach(viewModel.officialResults, id: \.id) { template in
                        CustomListCellView(
                            imageName: template.imageURL,
                            title: template.name,
                            subtitle: template.description
                        )
                        .anyButton(.highlight) {
                            viewModel.onSelect(template)
                        }
                        .removeListRowFormatting()
                    }
                } header: {
                    Text(viewModel.configuration.officialSectionTitle)
                }
            }
            if !viewModel.isLoading && viewModel.userResults.isEmpty && viewModel.officialResults.isEmpty {
                Section {
                    Text(viewModel.configuration.emptyStateMessage)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(viewModel.configuration.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { 
                Button("Cancel", action: viewModel.onCancel) 
            }
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) {
            Task { await viewModel.runSearch() }
        }
        .task {
            await viewModel.loadTopTemplates()
        }
        .showCustomAlert(alert: $viewModel.error)
    }
}
