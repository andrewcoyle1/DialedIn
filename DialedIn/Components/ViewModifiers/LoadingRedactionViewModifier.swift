//
//  LoadingRedactionViewModifier.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI

struct LoadingRedactionViewModifier: ViewModifier {
    var isLoading: Bool
    func body(content: Content) -> some View {
        if isLoading {
            content
                .redacted(reason: .placeholder)
        } else {
            content
        }
    }
}

extension View {
    func loadingRedaction(isLoading: Bool) -> some View {
        modifier(LoadingRedactionViewModifier(isLoading: isLoading))
    }
}
