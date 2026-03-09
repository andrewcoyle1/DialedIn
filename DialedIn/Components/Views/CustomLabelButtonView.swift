//
//  CustomLabelButtonView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/02/2026.
//

import SwiftUI

struct CustomLabelButtonView<Content: View>: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    let symbolName: String?
    let title: String
    let subtitle: String?
    var content: (() -> Content)?
    
    init(
        symbolName: String? = nil,
        title: String,
        subtitle: String? = nil,
        content: (() -> Content)? = nil
    ) {
        self.symbolName = symbolName
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }
    
    var body: some View {
        HStack {
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
            Spacer()
            content?()
        }
        .padding()
        .background(colorScheme.backgroundPrimary)
        .removeListRowFormatting()
    }
}

#Preview {
    
    List {

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

        CustomLabelButtonView(
            symbolName: "timer",
            title: "Rest Timer",
            subtitle: "Configure rest timer settings",
            content: {
                Image(systemName: "chevron.right")
                    .padding()
                    .anyButton(.press) {
                        print("Chevron pressed")
                    }
            }
        )
    }
}
