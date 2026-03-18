//
//  CallToActionButton.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/02/2026.
//

import SwiftUI

struct CallToActionButton<Content: View>: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var isPrimaryAction: Bool = true
    var action: () -> Void
    var label: () -> Content
    
    init(
        isPrimaryAction: Bool = true,
        action: @escaping () -> Void,
        label: @escaping () -> Content
    ) {
        self.isPrimaryAction = isPrimaryAction
        self.action = action
        self.label = label
    }
    
    var body: some View {
        ZStack {
            if isPrimaryAction {
                makeButton
                    .buttonStyle(.glassProminent)
            } else {
                makeButton
                    .buttonStyle(.glass)
            }
        }
        .padding(.horizontal)
    }
    
    private var makeButton: some View {
        Button {
            action()
        } label: {
            label()
                .foregroundStyle(isPrimaryAction ? colorScheme.backgroundPrimary : Color.primary)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    List {
        ForEach(FoodModel.mocks) { mock in
            Text(mock.name)
        }
    }
    .safeAreaInset(edge: .bottom) {
        VStack {
            CallToActionButton(isPrimaryAction: true) {
                
            } label: {
                Text("Create & Add")
            }
            CallToActionButton(isPrimaryAction: false) {
                
            } label: {
                Text("Create")
            }
        }
    }
}
