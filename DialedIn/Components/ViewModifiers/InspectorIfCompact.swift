//
//  InspectorIfCompact.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

struct InspectorIfCompact<InspectorContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let inspector: () -> InspectorContent
    let enabled: Bool

    func body(content: Content) -> some View {
        Group {
            if enabled {
                content
                    .inspector(isPresented: $isPresented) { self.inspector() }
            } else {
                content
            }
        }
    }
}
