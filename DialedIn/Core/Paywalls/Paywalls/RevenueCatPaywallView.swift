//
//  RevenueCatPaywallView.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/2/24.
//
import SwiftUI
import RevenueCat
import RevenueCatUI

struct RevenueCatPaywallView: View {
    
    var body: some View {
        RevenueCatUI.PaywallView(displayCloseButton: true)
    }
}

#Preview {
    RevenueCatPaywallView()
}
