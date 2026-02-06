//
//  MetricView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/02/2026.
//

import SwiftUI

struct MetricView: View {
    let label: String
    let value: String
    let icon: String
    var isLoading: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            if isLoading {
                Text(value)
                    .fontWeight(.medium)
                    .redacted(reason: .placeholder)
            } else {
                Text(value)
                    .fontWeight(.medium)
            }
        }
    }
}
