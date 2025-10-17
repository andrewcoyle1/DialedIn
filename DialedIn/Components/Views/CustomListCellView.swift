//
//  CustomListCellView.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/8/24.
//

import SwiftUI

struct CustomListCellView: View {
    
    var imageName: String? = Constants.randomImage
    var title: String? = "Alpha"
    var subtitle: String? = "An alien that is smiling in the park."
    var isSelected: Bool = false
    var iconName: String = "checkmark.circle.fill"
    var iconSize: CGFloat = 24
    var resizingMode: ContentMode = .fill
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                if let imageName {
                    if imageName.starts(with: "http://") || imageName.starts(with: "https://") {
                        ImageLoaderView(urlString: imageName, resizingMode: resizingMode)
                    } else {
                        // Treat as bundled asset name
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: resizingMode)
                    }
                } else {
                    Rectangle()
                        .fill(.secondary.opacity(0.5))
                }
                if isSelected {
                    Rectangle()
                        .fill(Color.white.opacity(0.6))
                    Rectangle()
                        .fill(Color.accent.opacity(0.1))
                    Image(systemName: iconName)
                        .foregroundStyle(Color.accent)
                        .font(.system(size: iconSize))
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(height: 60)
            .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 4) {
                if let title {
                    Text(title)
                        .font(.headline)
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .padding(.vertical, 4)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        List {
            CustomListCellView()
                .removeListRowFormatting()
            CustomListCellView(imageName: nil)
                .removeListRowFormatting()
            CustomListCellView(title: nil)
                .removeListRowFormatting()
            CustomListCellView(subtitle: nil)
                .removeListRowFormatting()
            CustomListCellView(isSelected: true)
                .removeListRowFormatting()
            CustomListCellView(imageName: nil, isSelected: true)
                .removeListRowFormatting()
            CustomListCellView(title: nil, isSelected: true)
                .removeListRowFormatting()
            CustomListCellView(subtitle: nil, isSelected: true)
                .removeListRowFormatting()
        }
    }
}
