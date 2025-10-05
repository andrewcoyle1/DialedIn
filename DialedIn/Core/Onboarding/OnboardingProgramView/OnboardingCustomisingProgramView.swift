//
//  OnboardingCustomisingProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingCustomisingProgramView: View {
    var body: some View {
        List {
            Text("Hello, World!")
        }
        .navigationTitle("Customise Program")
    }
}

#Preview {
    NavigationStack {
        OnboardingCustomisingProgramView()
    }
    .previewEnvironment()
}
