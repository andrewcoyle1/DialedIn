//
//  ProfilePreferencesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

struct ProfilePreferencesView: View {
    
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ProfilePreferencesViewModel
    var body: some View {
        Section {
            NavigationLink {
                SettingsView(viewModel: SettingsViewModel(container: container))
            } label: {
                ProfileSectionCard(
                    icon: "gearshape",
                    iconColor: .gray,
                    title: "Preferences"
                ) {
                    if let user = viewModel.currentUser {
                        VStack(spacing: 8) {
                            MetricRow(
                                label: "Units",
                                value: viewModel.formatUnitPreferences(
                                    length: user.lengthUnitPreference,
                                    weight: user.weightUnitPreference
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ProfilePreferencesView(viewModel: ProfilePreferencesViewModel(container: DevPreview.shared.container))
}
