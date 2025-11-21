//
//  RecipeDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI
import CustomRouting

struct RecipeDetailViewDelegate {
    let recipeTemplate: RecipeTemplateModel
}

struct RecipeDetailView: View {

    @Environment(\.dismiss) private var dismiss

    @State var viewModel: RecipeDetailViewModel

    let delegate: RecipeDetailViewDelegate

    var body: some View {
        List {
            if let url = delegate.recipeTemplate.imageURL {
                imageSection(url: url)
            }

            Section(header: Text("Ingredients")) {
                ForEach(delegate.recipeTemplate.ingredients) { wrapper in
                    ingredientSection(wrapper: wrapper)
                }
            }
        }
        .navigationTitle(delegate.recipeTemplate.name)
        .navigationSubtitle(delegate.recipeTemplate.description ?? "")
        .navigationBarTitleDisplayMode(.large)
        .showCustomAlert(alert: $viewModel.showAlert)
        .toolbar {
            toolbarContent
        }
        .onAppear { viewModel.loadInitialState(recipeTemplate: delegate.recipeTemplate)}
        .onChange(of: viewModel.currentUser) {_, _ in
            let user = viewModel.currentUser
            let isAuthor = user?.userId == delegate.recipeTemplate.authorId
            viewModel.isBookmarked = isAuthor || (user?.bookmarkedRecipeTemplateIds?.contains(delegate.recipeTemplate.id) ?? false) || (user?.createdRecipeTemplateIds?.contains(delegate.recipeTemplate.id) ?? false)
            viewModel.isFavourited = user?.favouritedRecipeTemplateIds?.contains(delegate.recipeTemplate.id) ?? false
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

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    await viewModel.onFavoritePressed(recipeTemplate: delegate.recipeTemplate)
                }
            } label: {
                Image(systemName: viewModel.isFavourited ? "heart.fill" : "heart")
            }
        }
        // Hide bookmark button when the current user is the author
        if viewModel.currentUser?.userId != nil && viewModel.currentUser?.userId != delegate.recipeTemplate.authorId {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.onBookmarkPressed(recipeTemplate: delegate.recipeTemplate)
                    }
                } label: {
                    Image(systemName: viewModel.isBookmarked ? "book.closed.fill" : "book.closed")
                }
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.onStartRecipePressed(recipe: delegate.recipeTemplate)
            } label: {
                Label("Start", systemImage: "play.fill")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.recipeDetailView(router: router, delegate: RecipeDetailViewDelegate(recipeTemplate: .mock))
    }
    .previewEnvironment()
}
