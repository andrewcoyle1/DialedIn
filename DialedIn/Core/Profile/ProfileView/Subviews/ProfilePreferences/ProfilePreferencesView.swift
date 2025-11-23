//
//  ProfilePreferencesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import CustomRouting

struct ProfilePreferencesView: View {

    @State var viewModel: ProfilePreferencesViewModel

    var body: some View {
        Section {
            Button {
                viewModel.navToSettingsView()
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
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        List {
            builder.profilePreferencesView(router: router)
        }
    }
    .previewEnvironment()
}
