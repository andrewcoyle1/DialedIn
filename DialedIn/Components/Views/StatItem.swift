//
//  StatItem.swift
//  DialedIn
//
//  Created by Andrew Coyle on 01/10/2025.
//

import SwiftUI

struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.footnote.bold())
        }
    }
}

#Preview("Exercise Count") {
    StatItem(title: "Exercise", value: "1/4")
}
