//
//  CachedProfileImageView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct CachedProfileImageView: View {
    let userId: String
    let imageUrl: String?
    let size: CGFloat
    
    @State private var image: PlatformImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image {
                #if canImport(UIKit)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                #elseif canImport(AppKit)
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                #endif
            } else if isLoading {
                ProgressView()
                    .frame(width: size, height: size)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundStyle(.accent)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        // First check cache
        if let cachedImage = ProfileImageCache.shared.getCachedImage(userId: userId) {
            image = cachedImage
            return
        }
        
        // If not cached and we have a URL, download it
        guard let urlString = imageUrl, !urlString.isEmpty else {
            return
        }
        
        isLoading = true
        
        do {
            let downloadedImage = try await ProfileImageCache.shared.downloadAndCache(from: urlString, userId: userId)
            image = downloadedImage
        } catch {
            // Failed to download, image will stay nil and show placeholder
            print("Failed to download profile image: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

#Preview {
    VStack(spacing: 20) {
        CachedProfileImageView(
            userId: "test-user",
            imageUrl: nil,
            size: 80
        )
        
        CachedProfileImageView(
            userId: "test-user-2",
            imageUrl: "https://example.com/image.jpg",
            size: 120
        )
    }
}
