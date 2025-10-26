//
//  MealDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct MealDetailView: View {
    let meal: MealLogModel
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    MealDetailView(meal: .mock)
        .previewEnvironment()
}
