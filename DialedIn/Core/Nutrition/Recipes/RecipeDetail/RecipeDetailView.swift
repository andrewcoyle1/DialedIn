//
//  RecipeDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI

struct RecipeDetailView: View {
    @State var viewModel: RecipeDetailViewModel
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            if let url = viewModel.recipeTemplate.imageURL {
                imageSection(url: url)
            }

            Section(header: Text("Ingredients")) {
                ForEach(viewModel.recipeTemplate.ingredients) { wrapper in
                    ingredientSection(wrapper: wrapper)
                }
            }
        }
        .navigationTitle(viewModel.recipeTemplate.name)
        .navigationSubtitle(viewModel.recipeTemplate.description ?? "")
        .navigationBarTitleDisplayMode(.large)
        .showCustomAlert(alert: $viewModel.showAlert)
        .toolbar {
            #if DEBUG || MOCK
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.showDebugView = true
                } label: {
                    Image(systemName: "info")
                }
            }
            #endif
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.onFavoritePressed()
                    }
                } label: {
                    Image(systemName: viewModel.isFavourited ? "heart.fill" : "heart")
                }
            }
            // Hide bookmark button when the current user is the author
            if viewModel.currentUser?.userId != nil && viewModel.currentUser?.userId != viewModel.recipeTemplate.authorId {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.onBookmarkPressed()
                        }
                    } label: {
                        Image(systemName: viewModel.isBookmarked ? "book.closed.fill" : "book.closed")
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showStartSessionSheet = true
                } label: {
                    Label("Start", systemImage: "play.fill")
                }
                .buttonStyle(.glassProminent)
            }
            
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
        .onAppear { viewModel.loadInitialState()}
        .onChange(of: viewModel.currentUser) {_, _ in
            let user = viewModel.currentUser
            let isAuthor = user?.userId == viewModel.recipeTemplate.authorId
            viewModel.isBookmarked = isAuthor || (user?.bookmarkedRecipeTemplateIds?.contains(viewModel.recipeTemplate.id) ?? false) || (user?.createdRecipeTemplateIds?.contains(viewModel.recipeTemplate.id) ?? false)
            viewModel.isFavourited = user?.favouritedRecipeTemplateIds?.contains(viewModel.recipeTemplate.id) ?? false
        }
        .sheet(isPresented: $viewModel.showStartSessionSheet) {
            RecipeStartView(recipe: viewModel.recipeTemplate)
        }
    }
    
    private func imageSection(url: String) -> some View {
        Section {
            ImageLoaderView(urlString: url, resizingMode: .fill)
                .frame(maxWidth: .infinity, minHeight: 180)
        }
        .removeListRowFormatting()
    }
    
    private func ingredientSection(wrapper: RecipeIngredientModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(wrapper.ingredient.name)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(Int(wrapper.amount)) \(viewModel.displayUnit(wrapper.unit))")
                    .foregroundStyle(.secondary)
            }
            if let notes = wrapper.ingredient.description, !notes.isEmpty {
                Text(notes)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(
            viewModel: RecipeDetailViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                recipeTemplate: RecipeTemplateModel.mock
            )
        )
    }
    .previewEnvironment()
}
