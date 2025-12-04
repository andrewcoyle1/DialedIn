//
//  ProfilePreferencesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ProfilePreferencesView: View {

    @State var presenter: ProfilePreferencesPresenter

    var body: some View {
        Section {
            Button {
                presenter.navToSettingsView()
            } label: {
                if let user = presenter.currentUser {
                    VStack(spacing: 8) {
                        MetricRow(
                            label: "Units",
                            value: presenter.formatUnitPreferences(
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
