//
//  SearchView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

struct SearchView: View {

    @State var presenter: SearchPresenter

    var body: some View {
        List {
            Text("Search View")
        }
        .navigationTitle("Search")
        .searchable(text: $presenter.searchString)
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
    let builder = CoreBuilder(container: DevPreview.shared.container)

    RouterView { router in
        builder.searchView(router: router)
    }
}
