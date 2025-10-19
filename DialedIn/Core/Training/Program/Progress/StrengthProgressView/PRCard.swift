//
//  PRCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct PRCard: View {
    let record: PersonalRecord
    let isSelected: Bool
    
    var body: some View {
        HStack {
            PersonalRecordRow(record: record)
            Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                .font(.caption)
                .foregroundStyle(isSelected ? .blue : .secondary)
        }
        
    }
}

#Preview("Not Selected") {
    PRCard(record: PersonalRecord.mock, isSelected: false)
        .previewEnvironment()
}

#Preview("Selected") {
    PRCard(record: PersonalRecord.mock, isSelected: true)
        .previewEnvironment()
}
