//
//  SearchView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

struct SearchView: View {

    @State private var searchString: String = ""
    
    var body: some View {
        List {
            Text("Search View")
        }
        .searchable(text: $searchString)
    }
}

#Preview {
    SearchView()
}
