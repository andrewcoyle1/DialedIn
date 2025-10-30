//
//  CopyWeekPickerSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI

struct CopyWeekPickerSheet: View {
    let availableWeeks: [Int]
    let onSelect: (Int) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                if availableWeeks.isEmpty {
                    Text("No previous weeks available")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(availableWeeks, id: \.self) { week in
                        Button {
                            onSelect(week)
                        } label: {
                            HStack {
                                Text("Week \(week)")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Copy from Week")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}

#Preview {
    CopyWeekPickerSheet(
        availableWeeks: [1, 2, 3],
        onSelect: { week in
            print("Selected week \(week)")
        },
        onCancel: {
            print("Cancel")
        }
    )
}
