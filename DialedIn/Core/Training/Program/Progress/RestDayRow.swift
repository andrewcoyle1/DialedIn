//
//  RestDayRow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct RestDayRow: View {
    let date: Date
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "moon.zzz.fill")
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Rest Day")
                    .font(.subheadline)
                MetricView(
                    label: "Date",
                    value: date.formatted(.dateTime.day().month()),
                    icon: "calendar")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    List {
        RestDayRow(date: Date())
    }
}
