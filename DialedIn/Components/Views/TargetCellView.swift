//
//  TargetCellView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/10/2025.
//

import SwiftUI

struct TargetCellView: View {
    let value: Double
    let targetValue: Double
    let maxValue: Double
    let unit: String
    var tint: Color = .accentColor
    
    private var clampedProgress: Double {
        guard maxValue > 0 else { return 0 }
        return max(0, min(1, value / maxValue))
    }
    
    private var targetProgress: Double {
        guard maxValue > 0 else { return 0 }
        return max(0, min(1, targetValue / maxValue))
    }
    
    var body: some View {
        GeometryReader { outerGeo in
            let availableWidth = outerGeo.size.width
            let cellHeight = availableWidth * 1.2 // 1:1.2 width:height aspect ratio
            let progressBarWidth = max(10, availableWidth * 0.65)
            let padding = max(4, availableWidth * 0.06)
            
            ZStack {
                ZStack {
                    ProgressView(value: clampedProgress)
                        .progressViewStyle(.linear)
                        .tint(tint.opacity(0.5))
                        .frame(width: progressBarWidth, height: 10)
                        .padding(padding)
                    GeometryReader { geo in
                        let width: CGFloat = geo.size.width
                        let height: CGFloat = geo.size.height
                        let progress = CGFloat(targetProgress)
                        let xPosition: CGFloat = max(0, min(width, width * progress))
                        Path { path in
                            // Draw a small tick mark perpendicular to the track
                            let halfHeight: CGFloat = height / 2
                            path.move(to: CGPoint(x: xPosition, y: halfHeight - 6))
                            path.addLine(to: CGPoint(x: xPosition, y: halfHeight + 6))
                        }
                        .stroke(Color.secondary, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .allowsHitTesting(false)
                    }
                    .frame(width: progressBarWidth, height: progressBarWidth)
                    .padding(padding)
                }
                .rotationEffect(.degrees(270))
            }
            .frame(width: availableWidth, height: cellHeight)
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1/1.2, contentMode: .fit) // 1:2 width:height ratio
    }
}

#Preview {
    TargetCellView(value: 160, targetValue: 180, maxValue: 220, unit: "g", tint: .blue)
}
