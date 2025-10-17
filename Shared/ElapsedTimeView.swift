//
//  ElapsedTimeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

struct ElapsedTimeView: View {
    var elapsedTime: TimeInterval = 0
    
    private static let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    var body: some View {
        Text(Self.componentsFormatter.string(from: elapsedTime) ?? "00:00")
            .fontWeight(.semibold)
    }
}

#Preview {
    ElapsedTimeView()
}
