//
//  OnboardingCompleteAccountSetupView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingCompleteAccountSetupView: View {
    var body: some View {
        VStack {
            Text("Complete Account Setup")
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationStack {
        OnboardingCompleteAccountSetupView()
    }
    .previewEnvironment()
}
