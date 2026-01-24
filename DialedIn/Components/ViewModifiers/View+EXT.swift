//
//  View+EXT.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/6/24.
//

import SwiftUI

extension View {
    
    func callToActionButton(isPrimaryAction: Bool = false) -> some View {
        modifier(CtaButtonViewModifier(isPrimaryAction: isPrimaryAction))
    }
    
    func badgeButton() -> some View {
        self
            .font(.caption)
            .bold()
            .foregroundStyle(Color.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.blue)
            .cornerRadius(6)
    }
    
    func tappableBackground() -> some View {
        background(Color.black.opacity(0.001))
    }
    
    func removeListRowFormatting() -> some View {
        self
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
    }
    
    func addingGradientBackgroundForText() -> some View {
        background(
            LinearGradient(colors: [
                Color.black.opacity(0),
                Color.black.opacity(0.3),
                Color.black.opacity(0.4)
            ], startPoint: .top, endPoint: .bottom)
        )
    }
    
    @ViewBuilder
    func ifSatisfiedCondition(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func any() -> AnyView {
        AnyView(self)
    }
}

struct CtaButtonViewModifier: ViewModifier {

    @Environment(\.colorScheme) private var colorScheme
    
    var isPrimaryAction: Bool

    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundStyle(isPrimaryAction ? .white : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isPrimaryAction ? .accent : .secondary, in: .capsule)
    }
}
