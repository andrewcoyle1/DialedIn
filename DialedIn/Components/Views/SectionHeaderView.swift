//
//  SectionHeaderView.swift
//  DialedIn
//
//  The list section header shared by every tab. It began life as `AnalyticsSectionHeader` and was
//  used only by the Analytics tab, so the Dashboard grew plain `Text` headers instead and its
//  sections had no way to offer a destination. One header, so a new section cannot pick a
//  different treatment.
//

import SwiftUI

/// A section title with an optional trailing action. Sections without a destination simply omit the
/// action and get the title alone.
struct SectionHeaderView: View {

    let title: String
    /// The trailing link's wording. "See All" suits a grid that is showing a subset; a feed that is
    /// already showing everything wants something else ("Find People").
    var actionTitle: String = "See All"
    var onActionPressed: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)

            if let onActionPressed {
                Spacer()
                Text(actionTitle)
                    .font(.caption)
                    .underline()
                    .anyButton(.press, action: onActionPressed)
            }
        }
    }
}

#Preview {
    List {
        Section {
            Text("Row")
        } header: {
            SectionHeaderView(title: "With Action", onActionPressed: { })
        }

        Section {
            Text("Row")
        } header: {
            SectionHeaderView(title: "Title Only")
        }
    }
}
