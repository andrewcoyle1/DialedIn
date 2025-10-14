//
//  MacroLabel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct MacroLabel: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.caption.bold())
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    MacroLabel(title: "Calories", value: 5)
}
