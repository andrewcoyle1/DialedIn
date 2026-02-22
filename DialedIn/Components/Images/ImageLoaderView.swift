//
//  ImageLoaderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI
import SDWebImageSwiftUI

/// Type-erased `Shape` so we can store shapes as properties without using `any Shape`.
struct AnyShape: Shape {
    private let _path: @Sendable (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        self._path = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

struct ImageLoaderView: View {
    
    var urlString: String = Constants.randomImage
    var resizingMode: ContentMode = .fill
    var forceTransitionAnimation: Bool = false
    var clipShape: AnyShape = AnyShape(Rectangle())
    
    var body: some View {
        clipShape
            .opacity(0.001)
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
            .clipShape(clipShape)
            .ifSatisfiedCondition(forceTransitionAnimation) { content in
                content
                    .drawingGroup()
            }
    }
}

#Preview {
    VStack {
        ImageLoaderView(clipShape: AnyShape(Rectangle()))
            .frame(width: 100, height: 200)
            .anyButton(.highlight) {

            }

        ImageLoaderView(clipShape: AnyShape(Circle()))
            .frame(width: 100)
            .anyButton(.highlight) {

            }
        Spacer()
    }
}
