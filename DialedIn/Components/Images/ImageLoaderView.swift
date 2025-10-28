//
//  ImageLoaderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageLoaderView: View {
    
    var urlString: String = Constants.randomImage
    var resizingMode: ContentMode = .fill
    var forceTransitionAnimation: Bool = false
    
    var body: some View {
        Rectangle()
            .opacity(0.5)
            .overlay(
                Group {
                    if urlString.starts(with: "http://") || urlString.starts(with: "https://") {
                        // Remote URL - use WebImage
                        WebImage(url: URL(string: urlString))
                            .resizable()
                            .indicator(.activity)
                            .aspectRatio(contentMode: resizingMode)
                            .allowsHitTesting(false)
                    } else {
                        // Bundled asset - use SwiftUI Image
                        Image(urlString)
                            .resizable()
                            .aspectRatio(contentMode: resizingMode)
                            .allowsHitTesting(false)
                    }
                }
            )
            .clipped()
            .ifSatisfiedCondition(forceTransitionAnimation) { content in
                content
                    .drawingGroup()
            }
    }
}

#Preview {
    ImageLoaderView()
        .frame(width: 100, height: 200)
        .anyButton(.highlight) {
            
        }
}
