//
//  StatItem.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/03/2026.
//

import SwiftUI

struct StatItem: View {
    
    var alignment: HorizontalAlignment = .leading
    var header: String
    var value: String
    
    var body: some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(header)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
