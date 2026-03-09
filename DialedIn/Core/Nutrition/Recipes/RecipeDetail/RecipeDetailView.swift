//
//  RecipeDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI

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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
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
                presenter.onStartRecipePressed(recipe: delegate.recipeTemplate)
            } label: {
                Label("Start", systemImage: "play.fill")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

extension CoreBuilder {
    func recipeDetailView(router: AnyRouter, delegate: RecipeDetailDelegate) -> some View {
        RecipeDetailView(
            presenter: RecipeDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showRecipeDetailView(delegate: RecipeDetailDelegate) {
        router.showScreen(.sheet) { router in
            builder.recipeDetailView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.recipeDetailView(router: router, delegate: RecipeDetailDelegate(recipeTemplate: .mock))
    }
    
}
