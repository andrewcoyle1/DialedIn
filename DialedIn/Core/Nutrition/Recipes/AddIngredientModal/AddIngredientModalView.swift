//
//  AddIngredientModalView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct AddIngredientModalView: View {
    @State var viewModel: AddIngredientModalViewModel
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedIngredients: [IngredientTemplateModel]
    
    private var filteredIngredients: [IngredientTemplateModel] {
        let query = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return viewModel.ingredients }
        return viewModel.ingredients.filter { ingredient in
            var fields: [String] = [
                ingredient.name
            ]
            if let description = ingredient.description { fields.append(description) }
            return fields.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                        Text("Loading ingredients...")
                            .foregroundStyle(.secondary)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text("Error Loading Ingredients")
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task {
                                await viewModel.loadIngredients()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(filteredIngredients) { ingredient in
                            CustomListCellView(imageName: ingredient.imageURL, title: ingredient.name, subtitle: ingredient.description, isSelected: selectedIngredients.contains(where: { $0.id == ingredient.id }))
                                .anyButton {
                                    viewModel.onIngredientPressed(ingredient: ingredient, selectedIngredients: &selectedIngredients)
                                }
                                .removeListRowFormatting()
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Add Ingredients")
            .navigationSubtitle("Select one or more ingredients to add")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.onDismissPressed(
                            onDismiss: {
                                dismiss()
                            }
                        )
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .task {
                await viewModel.loadIngredients()
            }
            .onChange(of: viewModel.searchText) {
                Task {
                    await viewModel.searchIngredients()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var showModal: Bool = true
    @Previewable @State var selectedIngredients: [IngredientTemplateModel] = [IngredientTemplateModel.mock]
    Button("Show Modal") {
        showModal = true
    }
    .sheet(isPresented: $showModal) {
        AddIngredientModalView(viewModel: AddIngredientModalViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), selectedIngredients: $selectedIngredients)
    }
    .previewEnvironment()
}
