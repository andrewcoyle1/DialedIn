//
//  CustomListCellView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/8/24.
//

import SwiftUI

struct CustomListCellView: View {
    
    var imageName: String? = Constants.randomImage
    var sfSymbolName: String? = "person"
    var imageHeight: CGFloat = 60
    var title: String? = "Alpha"
    var subtitle: String? = "An alien that is smiling in the park."
    var isSelected: Bool = false
    var iconName: String = "checkmark.circle.fill"
    var iconSize: CGFloat = 24
    var resizingMode: ContentMode = .fill
    var verticalPadding: CGFloat = 4

    init() {
        imageName = Constants.randomImage
        sfSymbolName = "person"
        imageHeight = 60
        title = "Alpha"
        subtitle = "An alien that is smiling in the park."
        isSelected = false
        iconName = "checkmark.circle.fill"
        iconSize = 24
        resizingMode = .fill
        verticalPadding = 4
    }

    init(
        imageName: String? = nil,
        sfSymbolName: String? = nil,
        imageHeight: CGFloat = 60,
        title: String? = nil,
        subtitle: String? = nil,
        isSelected: Bool = false,
        iconName: String = "person",
        iconSize: CGFloat = 24,
        resizingMode: ContentMode = .fill,
        verticalPadding: CGFloat = 4
    ) {
        self.imageName = imageName
        self.sfSymbolName = sfSymbolName
        self.imageHeight = imageHeight
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.iconName = iconName
        self.iconSize = iconSize
        self.resizingMode = resizingMode
        self.verticalPadding = verticalPadding
    }

    init(sfSymbolName: String, title: String? = nil, subtitle: String? = nil) {
        self.imageName = nil
        self.sfSymbolName = sfSymbolName
        self.imageHeight = 30
        self.title = title
        self.subtitle = subtitle
        self.isSelected = false
        self.iconName = "checkmark.circle.fill"
        self.iconSize = 24
        self.resizingMode = ContentMode.fill
        self.verticalPadding = 0

    }

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
                } else if let sfSymbolName {
                    Image(systemName: sfSymbolName)
                        .frame(width: 20)
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
            .frame(height: imageHeight)
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
        .padding(.vertical, verticalPadding)
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
