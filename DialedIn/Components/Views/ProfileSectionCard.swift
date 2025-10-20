//
//  ProfileSectionCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct ProfileSectionCard<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: Content
    let showChevron: Bool
    
    init(
        icon: String,
        iconColor: Color = .accent,
        title: String,
        showChevron: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.showChevron = showChevron
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)
                    .frame(width: 28)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
            
            content
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        Section {
            NavigationLink {
                Text("Detail View")
            } label: {
                ProfileSectionCard(
                    icon: "figure.walk",
                    title: "Physical Metrics"
                ) {
                    VStack(spacing: 8) {
                        MetricRow(label: "Height", value: "175 cm")
                        MetricRow(label: "Weight", value: "70 kg")
                        MetricRow(label: "BMI", value: "22.9")
                    }
                }
            }
        }
        
        Section {
            ProfileSectionCard(
                icon: "target",
                iconColor: .green,
                title: "Current Goal",
                showChevron: false
            ) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Lose Weight")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("70 kg → 65 kg")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
