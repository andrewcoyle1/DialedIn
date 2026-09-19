//
//  DashboardCard.swift
//  DialedIn
//
//  The frame the Dashboard's carousel cards share. Today's Workout, Workout Streak and Nutrition
//  each drew their own title and rounded surface, and each sized itself differently — one had no
//  height at all, one put 200pt on the surface, one put it on the title and surface together — so
//  the three pages of a single `TabView` did not line up with each other.
//

import SwiftUI

struct DashboardCard<Content: View>: View {

    @Environment(\.colorScheme) private var colorScheme

    let title: String
    /// Cards whose content brings its own surface (the Today's Workout label styles itself) opt out
    /// of the rounded background rather than nesting two.
    var drawsSurface: Bool = true
    @ViewBuilder var content: () -> Content

    /// One height for every page of the Dashboard carousel.
    static var contentHeight: CGFloat { 200 }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.leading)

            surface
                .frame(height: Self.contentHeight)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var surface: some View {
        if drawsSurface {
            content()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(colorScheme.backgroundPrimary, in: .rect(cornerRadius: 24))
        } else {
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    DashboardCard(title: "Workout Streak") {
        VStack(alignment: .leading) {
            Text("12 days")
                .font(.largeTitle.bold())
            Spacer()
            Text("Best streak 21 days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
