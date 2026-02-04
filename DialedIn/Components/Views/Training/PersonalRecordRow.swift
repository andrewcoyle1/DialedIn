//
//  PersonalRecordRow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct PersonalRecordRow: View {
    let record: PersonalRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.exerciseName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(record.weight)) kg × \(record.reps)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 4) {
                    Text("1RM: \(Int(record.estimatedOneRepMax)) kg")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let improvement = record.improvement {
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.up")
                                .font(.caption2)
                            Text("+\(String(format: "%.1f%%", improvement))")
                                .font(.caption)
                        }
                        .foregroundStyle(.green)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PersonalRecordRow(record: PersonalRecord.mock)
        .padding()
        .previewEnvironment()
}
