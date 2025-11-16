//
//  ProfilePreferencesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

struct ProfilePreferencesViewDelegate {
    var path: Binding<[TabBarPathOption]>
}

struct ProfilePreferencesView: View {

    @State var viewModel: ProfilePreferencesViewModel

    var delegate: ProfilePreferencesViewDelegate

    var body: some View {
        Section {
            Button {
                viewModel.navToSettingsView(path: delegate.path)
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
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        List {
            builder.profilePreferencesView(delegate: ProfilePreferencesViewDelegate(path: $path))
        }
    }
    .previewEnvironment()
}
