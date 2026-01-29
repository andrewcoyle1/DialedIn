//
//  InteractionReaderViewModifier.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/01/2026.
//

import SwiftUI

struct InteractionReaderViewModifier: ViewModifier {

    var longPressSensitivity: Int
    var tapAction: () -> Void
    var longPressAction: () -> Void
    var scaleEffect: Bool = true

    @State private var isPressing: Bool = Bool()
    @State private var currentDismissId: DispatchTime = DispatchTime.now()
    @State private var lastInteractionKind: String = String()

    func body(content: Content) -> some View {

        let processedContent = content
            .gesture(gesture)
            .onChange(of: isPressing) { _, _ in

                currentDismissId = DispatchTime.now() + .milliseconds(longPressSensitivity)
                let dismissId: DispatchTime = currentDismissId

                if isPressing {
                    DispatchQueue.main.asyncAfter(deadline: dismissId) {
                        if isPressing && dismissId == currentDismissId {
                            lastInteractionKind = "longPress"; longPressAction()
                        }
                    }
                } else {
                    if lastInteractionKind != "longPress" { lastInteractionKind = "tap"; tapAction() }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {lastInteractionKind = "none"}
                }

            }

        return Group {

            if scaleEffect {
                processedContent.scaleEffect(lastInteractionKind == "longPress" ? 1.5: (lastInteractionKind == "tap" ? 0.8 : 1.0 ))
            } else {
                processedContent
            }
        }
    }

    var gesture: some Gesture {

        DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
            .onChanged { _ in
                if !isPressing {
                    isPressing = true
                }
            }
            .onEnded { _ in
                isPressing = false
            }
    }
}
