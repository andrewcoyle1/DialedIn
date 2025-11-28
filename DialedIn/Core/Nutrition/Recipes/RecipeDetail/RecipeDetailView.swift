//
//  RecipeDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI
import CustomRouting

struct RecipeDetailView: View {

    @State var presenter: RecipeDetailPresenter

    let delegate: RecipeDetailDelegate

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
        .toolbar {
            toolbarContent
        }
        .onAppear { presenter.loadInitialState(recipeTemplate: delegate.recipeTemplate)}
        .onChange(of: presenter.currentUser) {_, _ in
            let user = presenter.currentUser
            let isAuthor = user?.userId == delegate.recipeTemplate.authorId
            presenter.isBookmarked = isAuthor || (user?.bookmarkedRecipeTemplateIds?.contains(delegate.recipeTemplate.id) ?? false) || (user?.createdRecipeTemplateIds?.contains(delegate.recipeTemplate.id) ?? false)
            presenter.isFavourited = user?.favouritedRecipeTemplateIds?.contains(delegate.recipeTemplate.id) ?? false
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
                Text("\(Int(wrapper.amount)) \(presenter.displayUnit(wrapper.unit))")
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
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    await presenter.onFavoritePressed(recipeTemplate: delegate.recipeTemplate)
                }
            } label: {
                Image(systemName: presenter.isFavourited ? "heart.fill" : "heart")
            }
        }
        // Hide bookmark button when the current user is the author
        if presenter.currentUser?.userId != nil && presenter.currentUser?.userId != delegate.recipeTemplate.authorId {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await presenter.onBookmarkPressed(recipeTemplate: delegate.recipeTemplate)
                    }
                } label: {
                    Image(systemName: presenter.isBookmarked ? "book.closed.fill" : "book.closed")
                }
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onStartRecipePressed(recipe: delegate.recipeTemplate)
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
        builder.recipeDetailView(router: router, delegate: RecipeDetailDelegate(recipeTemplate: .mock))
    }
    .previewEnvironment()
}
