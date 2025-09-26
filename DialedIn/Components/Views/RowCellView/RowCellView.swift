//
//  ChatRowCellView.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/8/24.
//

import SwiftUI

struct RowCellView: View {
    
    var imageName: String? = Constants.randomImage
    var isUploading: Bool = false
    var headline: String? = "Alpha"
    var subheadline: String? = "This is the last message in the chat."
    var hasNewReview: Bool = true
    var trailingBadge: String?
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                if isUploading && imageName == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let imageName {
                    ImageLoaderView(urlString: imageName)
                } else {
                    Rectangle()
                        .fill(.secondary.opacity(0.5))
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                if let headline {
                    Text(headline)
                        .font(.headline)
                }
                if let subheadline {
                    Text(subheadline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if let trailingBadge {
                Text(trailingBadge)
                    .badgeButton()
            } else if hasNewReview {
                Text("NEW")
                    .badgeButton()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(uiColor: UIColor.systemBackground))
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        List {
            RowCellView()
                .removeListRowFormatting()
            RowCellView(hasNewReview: false)
                .removeListRowFormatting()
            RowCellView(imageName: nil)
                .removeListRowFormatting()
            RowCellView(headline: nil, hasNewReview: false)
                .removeListRowFormatting()
            RowCellView(subheadline: nil, hasNewReview: false)
                .removeListRowFormatting()
        }
    }
}
