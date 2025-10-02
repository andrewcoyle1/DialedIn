//
//  AddIngredientModal.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct AddIngredientModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(IngredientTemplateManager.self) private var ingredientTemplateManager
    @Environment(LogManager.self) private var logManager
    
    @State private var ingredients: [IngredientTemplateModel] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    @Binding var selectedIngredients: [IngredientTemplateModel]
    
    private var filteredIngredients: [IngredientTemplateModel] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return ingredients }
        return ingredients.filter { ingredient in
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
                if isLoading {
                    VStack {
                        ProgressView()
                        Text("Loading ingredients...")
                            .foregroundStyle(.secondary)
                    }
                } else if let errorMessage = errorMessage {
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
                                await loadIngredients()
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
                                    onIngredientPressed(ingredient: ingredient)
                                }
                                .removeListRowFormatting()
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Add Ingredients")
            .navigationSubtitle("Select one or more ingredients to add")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onDismissPressed()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .task {
                await loadIngredients()
            }
            .onChange(of: searchText) {
                Task {
                    await searchIngredients()
                }
            }
        }
    }
    
    private func onIngredientPressed(ingredient: IngredientTemplateModel) {
        if let index = selectedIngredients.firstIndex(where: { $0.id == ingredient.id }) {
            selectedIngredients.remove(at: index)
        } else {
            selectedIngredients.append(ingredient)
        }
    }
    private func onDismissPressed() {
        dismiss()
    }
    
    private func loadIngredients() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            // Load top ingredients when not searching
            let loadedIngredients = try await ingredientTemplateManager.getTopIngredientTemplatesByClicks(limitTo: 50)
            await MainActor.run {
                ingredients = loadedIngredients
                isLoading = false
            }
        } catch {
            // Fallback to local ingredients if remote fails
            do {
                let localIngredients = try ingredientTemplateManager.getAllLocalIngredientTemplates()
                await MainActor.run {
                    ingredients = localIngredients
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to load ingredients. Please check your connection and try again."
                }
            }
        }
    }
    
    private func searchIngredients() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If search is empty, reload top ingredients
        guard !query.isEmpty else {
            await loadIngredients()
            return
        }
        
        // Don't search for very short queries to avoid too many API calls
        guard query.count >= 2 else { return }
        
        do {
            let searchResults = try await ingredientTemplateManager.getIngredientTemplatesByName(name: query)
            await MainActor.run {
                ingredients = searchResults
            }
        } catch {
            // Don't show error for search failures, just keep current results
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
        AddIngredientModal(selectedIngredients: $selectedIngredients)
    }
    .previewEnvironment()
}
