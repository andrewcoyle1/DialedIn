//
//  CustomToggleView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/02/2026.
//

import SwiftUI

struct CustomToggleView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    let symbolName: String?
    let title: String
    let subtitle: String?
    let bool: Binding<Bool>
    
    init(
        symbolName: String? = nil,
        title: String,
        subtitle: String? = nil,
        bool: Binding<Bool>
    ) {
        self.symbolName = symbolName
        self.title = title
        self.subtitle = subtitle
        self.bool = bool
    }
    
    var body: some View {
        Toggle(isOn: bool) {
            if let symbolName {
                Label {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: symbolName)
                        .frame(width: 44, height: 44, alignment: .center)
                }
            } else {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
        }
        .padding()
        .background(colorScheme.backgroundPrimary)
        .removeListRowFormatting()
    }
}

#Preview {
    @Previewable @State var isOn: Bool = true
    
    List {
        CustomToggleView(
            symbolName: "sun.max",
            title: "Keep Alive",
            subtitle: "Keep your phone alive during active workout sessions",
            bool: $isOn
        )

        CustomLabelButtonView(
            symbolName: "wand.and.stars",
            title: "Smart Progression",
            subtitle: "Configure smart progression settings",
            content: {
                Text("Edit")
                    .padding(.horizontal, 8)
                    .padding(8)
                    .background(Color.secondary.opacity(0.2), in: .capsule)
                    .anyButton(.press) {
                        print("Edit pressed")
                    }
            }
        )
    }
}
