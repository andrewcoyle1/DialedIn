//
//  AdaptivePresentationModifier.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

extension View {
    /// Presents a modal that adapts based on layout mode:
    /// - In tab bar mode: Uses fullScreenCover
    /// - In split view mode: Uses sheet
    func adaptiveFullScreenCover<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(AdaptiveFullScreenCoverModifier(
            isPresented: isPresented,
            onDismiss: onDismiss,
            content: content
        ))
    }
}

private struct AdaptiveFullScreenCoverModifier<ModalContent: View>: ViewModifier {
    @Environment(\.layoutMode) private var layoutMode
    
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    @ViewBuilder let content: () -> ModalContent
    
    func body(content: Content) -> some View {
        switch layoutMode {
        case .tabBar:
            content
                .fullScreenCover(isPresented: $isPresented, onDismiss: onDismiss) {
                    self.content()
                }
        case .splitView:
            content
                .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                    self.content()
                }
        }
    }
}
