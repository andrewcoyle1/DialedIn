//
//  MicrocycleItemRow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 15/03/2026.
//

import SwiftUI

struct MicrocycleItemRow: View {
    
    let item: MicrocycleItem
        
    var body: some View {
        HStack {
            WorkoutTemplateRow(workoutTemplate: item.workoutTemplate)
            Spacer()
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
//                .foregroundStyle(item.isCompleted ? .green : .secondary)
        }
        .opacity(item.isCompleted ? 0.3 : 1)
    }
}

#Preview {
    List {
        MicrocycleItemRow(item: .mock)
    }
}
