//
//  SearchView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

struct SearchView: View {

    @State var presenter: SearchPresenter

    @Namespace private var namespace

    var body: some View {
        List {
            Text("Search View")
        }
        .navigationTitle("Search")
        .searchable(text: $presenter.searchString)
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onProfilePressed("search-profile-button", in: namespace)
            } label: {
                if let urlString = presenter.userImageUrl {
                    ImageLoaderView(urlString: urlString)
                        .frame(minWidth: 44, maxWidth: .infinity, minHeight: 44, maxHeight: .infinity)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person")
                }
            }
            .matchedTransitionSource(id: "search-profile-button", in: namespace)
        }
        .sharedBackgroundVisibility(.hidden)

    }
}

extension CoreBuilder {
    func searchView(router: AnyRouter) -> some View {
        SearchView(
            presenter: SearchPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())

    RouterView { router in
        builder.searchView(router: router)
    }
}
