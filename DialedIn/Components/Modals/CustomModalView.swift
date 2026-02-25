//
//  CustomModalView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import SwiftUI

struct CustomModalView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    var title: String = "Title"
    var subtitle: String? = "This is a subtitle"
    var primaryButtonTitle: String = "Yes"
    var primaryButtonAction: () -> Void = { }
    var secondaryButtonTitle: String = "No"
    var secondaryButtonAction: () -> Void = { }
    // Optional middle content area for custom views (e.g., pickers)
    var middleContent: AnyView?

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.title)
                    .fontWeight(.semibold)
                if let subtitle {
                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

            }
            .padding(12)

            if let middleContent {
                middleContent
            }

            VStack(spacing: 8) {
                Button {
                    primaryButtonAction()
                } label: {
                    Text(primaryButtonTitle)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(colorScheme.foregroundSecondary)
                }
                .buttonStyle(.borderedProminent)

                Text(secondaryButtonTitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .tappableBackground()
                    .anyButton(.plain) {
                        secondaryButtonAction()
                    }
            }
        }
        .multilineTextAlignment(.center)
        .padding(16)
        .glassEffect(.regular, in: .rect)
        .cornerRadius(24)
        .padding(40)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        CustomModalView(
            title: "Are you enjoying Dialed?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: { },
            secondaryButtonTitle: "Not now",
            secondaryButtonAction: { }
        )
    }
}
