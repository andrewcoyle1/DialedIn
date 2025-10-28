//
//  AppViewBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct AppViewBuilder<TabBarView: View, OnboardingView: View>: View {
    
    var showTabBar: Bool = false
    @ViewBuilder var tabBarView: TabBarView
    @ViewBuilder var onboardingView: OnboardingView

    var body: some View {
        ZStack {
            if showTabBar {
                tabBarView
                    .transition(.move(edge: .trailing))
            } else {
                onboardingView
                    .transition(.move(edge: .leading))
            } 
        }
        .animation(.default, value: showTabBar)
    }
}

#Preview {
    @Previewable @State var showTabBar: Bool = false
    AppViewBuilder(
        showTabBar: showTabBar,
        tabBarView: {
            ZStack {
                Color.red.ignoresSafeArea()
                Text("Tab Bar View")
            }
        },
        onboardingView: {
            ZStack {
                Color.blue.ignoresSafeArea()
                Text("Onboarding View")
            }
        }
    )
    .onTapGesture {
        showTabBar.toggle()
    }
}
