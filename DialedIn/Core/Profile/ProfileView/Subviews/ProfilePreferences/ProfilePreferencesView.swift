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

    @Binding var path: [TabBarPathOption]

    var body: some View {
        Section {
            Button {
                viewModel.navToSettingsView(path: $path)
            } label: {
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
        } header: {
            HStack(spacing: 8) {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundStyle(.gray)
                    .frame(width: 28)
                
                Text("Preferences")
                    .font(.headline)
                
                Spacer()
            }
        }
    }
}

#Preview {
    @Previewable @State var path: [TabBarPathOption] = []
    ProfilePreferencesView(
        viewModel: ProfilePreferencesViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        ),
        path: $path
    )
}
