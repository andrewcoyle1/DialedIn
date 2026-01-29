//
//  ProgramTemplateCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramTemplateCard: View {
    let template: ProgramTemplateModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            nameSection
            difficultySection
            focusAreaSection
        }
        .padding(.vertical, 4)
    }
    
    private var nameSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(template.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
    
    private var difficultySection: some View {
        HStack(spacing: 12) {
            // Difficulty
            Label(template.difficulty.description, systemImage: template.difficulty.systemImage)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // Duration
            Label("\(template.duration) weeks", systemImage: "calendar")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var focusAreaSection: some View {
        // Focus areas
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(template.focusAreas, id: \.self) { focus in
                    Text(focus.description)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

#Preview {
    ProgramTemplateCard(template: ProgramTemplateModel.mock)
        .padding()
}
