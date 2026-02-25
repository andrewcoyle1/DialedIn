//
//  CallToActionButton.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/02/2026.
//

import SwiftUI

struct CallToActionButton<Content: View>: View {
    
    var isPrimaryAction: Bool = true
    var action: () -> Void
    var label: () -> Content
    
    var body: some View {
        Group {
            if isPrimaryAction {
                
                Button {
                    action()
                } label: {
                    label()
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
            } else {
                Button {
                    action()
                } label: {
                    label()
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
            }
        }
        .padding(.horizontal)
    }
}
